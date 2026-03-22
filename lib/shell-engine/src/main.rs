// bm-shell-engine — Generates zsh initialization from a JSON manifest.
//
// Replaces fragile Nix-generated shell code with a tested Rust program.
// Reads a JSON manifest (Nix → Rust machine boundary) and outputs correct
// zsh source commands to stdout. The .zshrc simply evals this output.
//
// Usage: bm-shell-engine <manifest.json>

use serde::Deserialize;
use std::env;
use std::fs;
use std::io::{self, BufWriter, Write};
use std::path::PathBuf;
use std::process;

#[derive(Deserialize)]
struct Manifest {
    #[serde(default)]
    pre_sources: Vec<String>,
    #[serde(default)]
    plugins_immediate: Vec<String>,
    #[serde(default)]
    plugins_deferred: Vec<String>,
    #[serde(default)]
    post_sources: Vec<String>,
    #[serde(default)]
    scan_dirs: Vec<String>,
    #[serde(default)]
    clean_paths: Vec<String>,
}

fn expand_tilde(path: &str) -> PathBuf {
    if let Some(rest) = path.strip_prefix("~/") {
        if let Ok(home) = env::var("HOME") {
            return PathBuf::from(home).join(rest);
        }
    }
    PathBuf::from(path)
}

fn source_if_exists(out: &mut impl Write, path: &str) -> bool {
    if expand_tilde(path).exists() {
        writeln!(out, "source {path}").unwrap();
        true
    } else {
        false
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        eprintln!("Usage: bm-shell-engine <manifest.json>");
        process::exit(1);
    }

    let json = fs::read_to_string(&args[1]).unwrap_or_else(|e| {
        eprintln!("bm-shell-engine: cannot read {}: {e}", args[1]);
        process::exit(1);
    });

    let manifest: Manifest = serde_json::from_str(&json).unwrap_or_else(|e| {
        eprintln!("bm-shell-engine: invalid manifest {}: {e}", args[1]);
        process::exit(1);
    });

    let stdout = io::stdout();
    let mut out = BufWriter::new(stdout.lock());

    // Phase 1: Clean stale cache files (side effect, no output)
    for path in &manifest.clean_paths {
        let expanded = expand_tilde(path);
        if expanded.exists() {
            let _ = fs::remove_file(&expanded);
        }
    }

    // Phase 2: Pre-plugin sources (settings, completion)
    for path in &manifest.pre_sources {
        source_if_exists(&mut out, path);
    }

    // Phase 3: Immediate plugins
    for path in &manifest.plugins_immediate {
        source_if_exists(&mut out, path);
    }

    // Phase 4: Post-plugin sources (editor, aliases)
    for path in &manifest.post_sources {
        source_if_exists(&mut out, path);
    }

    // Phase 5: Scan directories for *.zsh files (local overrides)
    for dir in &manifest.scan_dirs {
        let expanded = expand_tilde(dir);
        if !expanded.is_dir() {
            continue;
        }
        let Ok(read_dir) = fs::read_dir(&expanded) else {
            continue;
        };
        let mut entries: Vec<PathBuf> = read_dir
            .flatten()
            .map(|e| e.path())
            .filter(|p| p.extension().and_then(|e| e.to_str()) == Some("zsh") && p.is_file())
            .collect();
        entries.sort();
        for entry in &entries {
            writeln!(out, "source {}", entry.display()).unwrap();
        }
    }

    // Phase 6: Deferred plugins (precmd hook — fires once after first prompt)
    if !manifest.plugins_deferred.is_empty() {
        writeln!(out).unwrap();
        writeln!(out, "# ===== DEFERRED PLUGINS (loaded after first prompt) =====").unwrap();
        writeln!(out, "__blackmatter_deferred() {{").unwrap();
        writeln!(out, "  add-zsh-hook -d precmd __blackmatter_deferred").unwrap();
        writeln!(out, "  unfunction __blackmatter_deferred").unwrap();
        for path in &manifest.plugins_deferred {
            if expand_tilde(path).exists() {
                writeln!(out, "  source {path}").unwrap();
            }
        }
        writeln!(out, "}}").unwrap();
        writeln!(out, "autoload -Uz add-zsh-hook").unwrap();
        writeln!(out, "add-zsh-hook precmd __blackmatter_deferred").unwrap();
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn manifest_deserializes_empty() {
        let m: Manifest = serde_json::from_str("{}").unwrap();
        assert!(m.pre_sources.is_empty());
        assert!(m.plugins_immediate.is_empty());
        assert!(m.plugins_deferred.is_empty());
        assert!(m.post_sources.is_empty());
        assert!(m.scan_dirs.is_empty());
        assert!(m.clean_paths.is_empty());
    }

    #[test]
    fn manifest_deserializes_partial() {
        let json = r#"{"pre_sources":["~/.a.zsh"],"plugins_deferred":["~/.b.zsh"]}"#;
        let m: Manifest = serde_json::from_str(json).unwrap();
        assert_eq!(m.pre_sources, vec!["~/.a.zsh"]);
        assert_eq!(m.plugins_deferred, vec!["~/.b.zsh"]);
        assert!(m.plugins_immediate.is_empty());
    }

    #[test]
    fn manifest_deserializes_full() {
        let json = r#"{
            "pre_sources": ["/a"],
            "plugins_immediate": ["/b"],
            "plugins_deferred": ["/c"],
            "post_sources": ["/d"],
            "scan_dirs": ["/e"],
            "clean_paths": ["/f"]
        }"#;
        let m: Manifest = serde_json::from_str(json).unwrap();
        assert_eq!(m.pre_sources, vec!["/a"]);
        assert_eq!(m.plugins_immediate, vec!["/b"]);
        assert_eq!(m.plugins_deferred, vec!["/c"]);
        assert_eq!(m.post_sources, vec!["/d"]);
        assert_eq!(m.scan_dirs, vec!["/e"]);
        assert_eq!(m.clean_paths, vec!["/f"]);
    }

    #[test]
    fn expand_tilde_absolute_path() {
        assert_eq!(expand_tilde("/absolute/path"), PathBuf::from("/absolute/path"));
    }

    #[test]
    fn expand_tilde_with_home() {
        // Use the actual HOME env var (don't mutate — not thread-safe)
        let home = env::var("HOME").expect("HOME must be set in test env");
        let expected = PathBuf::from(&home).join("foo/bar");
        assert_eq!(expand_tilde("~/foo/bar"), expected);
    }

    #[test]
    fn expand_tilde_relative_path() {
        assert_eq!(expand_tilde("relative/path"), PathBuf::from("relative/path"));
    }

    #[test]
    fn source_if_exists_when_file_exists() {
        let dir = env::temp_dir().join("bm_shell_test");
        fs::create_dir_all(&dir).unwrap();
        let path = dir.join("exists.zsh");
        fs::write(&path, "").unwrap();
        let path_str = path.to_string_lossy().to_string();

        let mut out = Vec::new();
        let wrote = source_if_exists(&mut out, &path_str);
        assert!(wrote);
        let output = String::from_utf8(out).unwrap();
        assert!(output.starts_with("source "));
        assert!(output.contains(&path_str));

        let _ = fs::remove_dir_all(&dir);
    }

    #[test]
    fn source_if_exists_when_missing() {
        let mut out = Vec::new();
        let wrote = source_if_exists(&mut out, "/nonexistent/path/xyz.zsh");
        assert!(!wrote);
        assert!(out.is_empty());
    }
}
