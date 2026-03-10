// bm-shell-engine — Zero-dep Rust binary that generates shell initialization.
//
// Replaces fragile Nix-generated shell code with a tested Rust program.
// Reads a JSON manifest (Nix → Rust machine boundary) and outputs correct
// zsh source commands to stdout. The .zshrc simply evals this output.
//
// JSON manifest schema:
//   {
//     "pre_sources":        ["path", ...],  // sourced first (settings, completion)
//     "plugins_immediate":  ["path", ...],  // sourced in order
//     "plugins_deferred":   ["path", ...],  // wrapped in precmd hook
//     "post_sources":       ["path", ...],  // sourced after plugins (editor, aliases)
//     "scan_dirs":          ["dir", ...],   // glob *.zsh at runtime
//     "clean_paths":        ["path", ...]   // delete if exists (stale .zwc)
//   }
//
// Usage: bm-shell-engine <manifest.json>

use std::env;
use std::fs;
use std::io::{self, Write};
use std::path::PathBuf;
use std::process;

// ── Minimal zero-dep JSON parser (arrays of strings only) ──────────────────

fn parse_string_array(json: &str, key: &str) -> Vec<String> {
    let needle = format!("\"{}\"", key);
    let Some(key_pos) = json.find(&needle) else {
        return Vec::new();
    };
    let after_key = &json[key_pos + needle.len()..];

    // Skip whitespace and colon
    let after_colon = match after_key.find(':') {
        Some(pos) => &after_key[pos + 1..],
        None => return Vec::new(),
    };

    // Find array brackets
    let start = match after_colon.find('[') {
        Some(pos) => pos + 1,
        None => return Vec::new(),
    };
    let end = match after_colon.find(']') {
        Some(pos) => pos,
        None => return Vec::new(),
    };

    let array_content = &after_colon[start..end];
    let mut result = Vec::new();
    let mut chars = array_content.chars().peekable();

    while let Some(&c) = chars.peek() {
        if c == '"' {
            chars.next(); // consume opening quote
            let mut s = String::new();
            loop {
                match chars.next() {
                    None | Some('"') => break,
                    Some('\\') => match chars.next() {
                        Some('n') => s.push('\n'),
                        Some('t') => s.push('\t'),
                        Some('"') => s.push('"'),
                        Some('\\') => s.push('\\'),
                        Some('/') => s.push('/'),
                        Some(other) => {
                            s.push('\\');
                            s.push(other);
                        }
                        None => break,
                    },
                    Some(ch) => s.push(ch),
                }
            }
            result.push(s);
        } else {
            chars.next();
        }
    }
    result
}

// ── Path helpers ───────────────────────────────────────────────────────────

fn expand_tilde(path: &str) -> PathBuf {
    if let Some(rest) = path.strip_prefix("~/") {
        if let Ok(home) = env::var("HOME") {
            return PathBuf::from(home).join(rest);
        }
    }
    PathBuf::from(path)
}

// ── Main ───────────────────────────────────────────────────────────────────

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        eprintln!("Usage: bm-shell-engine <manifest.json>");
        process::exit(1);
    }

    let json = match fs::read_to_string(&args[1]) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("bm-shell-engine: cannot read {}: {}", args[1], e);
            process::exit(1);
        }
    };

    let pre_sources = parse_string_array(&json, "pre_sources");
    let plugins_immediate = parse_string_array(&json, "plugins_immediate");
    let plugins_deferred = parse_string_array(&json, "plugins_deferred");
    let post_sources = parse_string_array(&json, "post_sources");
    let scan_dirs = parse_string_array(&json, "scan_dirs");
    let clean_paths = parse_string_array(&json, "clean_paths");

    let stdout = io::stdout();
    let mut out = io::BufWriter::new(stdout.lock());

    // Phase 1: Clean stale cache files (side effect, no output)
    for path in &clean_paths {
        let expanded = expand_tilde(path);
        if expanded.exists() {
            let _ = fs::remove_file(&expanded);
        }
    }

    // Phase 2: Pre-plugin sources (settings, completion)
    for path in &pre_sources {
        let expanded = expand_tilde(path);
        if expanded.exists() {
            writeln!(out, "source {}", path).unwrap();
        }
    }

    // Phase 3: Immediate plugins
    for path in &plugins_immediate {
        let expanded = expand_tilde(path);
        if expanded.exists() {
            writeln!(out, "source {}", path).unwrap();
        }
    }

    // Phase 4: Post-plugin sources (editor, aliases)
    for path in &post_sources {
        let expanded = expand_tilde(path);
        if expanded.exists() {
            writeln!(out, "source {}", path).unwrap();
        }
    }

    // Phase 5: Scan directories for *.zsh files (local overrides)
    for dir in &scan_dirs {
        let expanded = expand_tilde(dir);
        if expanded.is_dir() {
            let mut entries: Vec<PathBuf> = Vec::new();
            if let Ok(read_dir) = fs::read_dir(&expanded) {
                for entry in read_dir.flatten() {
                    let path = entry.path();
                    if path.extension().and_then(|e| e.to_str()) == Some("zsh") && path.is_file()
                    {
                        entries.push(path);
                    }
                }
            }
            entries.sort();
            for entry in &entries {
                writeln!(out, "source {}", entry.display()).unwrap();
            }
        }
    }

    // Phase 6: Deferred plugins (precmd hook — fires once after first prompt)
    if !plugins_deferred.is_empty() {
        writeln!(out).unwrap();
        writeln!(
            out,
            "# ===== DEFERRED PLUGINS (loaded after first prompt) ====="
        )
        .unwrap();
        writeln!(out, "__blackmatter_deferred() {{").unwrap();
        writeln!(
            out,
            "  add-zsh-hook -d precmd __blackmatter_deferred"
        )
        .unwrap();
        writeln!(out, "  unfunction __blackmatter_deferred").unwrap();
        for path in &plugins_deferred {
            let expanded = expand_tilde(path);
            if expanded.exists() {
                writeln!(out, "  source {}", path).unwrap();
            }
        }
        writeln!(out, "}}").unwrap();
        writeln!(out, "autoload -Uz add-zsh-hook").unwrap();
        writeln!(out, "add-zsh-hook precmd __blackmatter_deferred").unwrap();
    }
}
