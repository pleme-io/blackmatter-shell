# Blackmatter Shell

Nord-themed zsh configuration with 7 curated plugins, 40+ autoload functions, and 35 bundled CLI tools (mostly Rust). Managed entirely by Nix — no runtime plugin managers.

## Install

### Standalone binary (try it without changing your system)

```bash
nix run github:pleme-io/blackmatter-shell
```

This launches `blzsh` — a self-contained zsh with its own ZDOTDIR, all plugins, tools, and configuration baked into the Nix store. Your system shell is untouched.

### Home Manager module (full integration)

```nix
# flake.nix
inputs.blackmatter-shell.url = "github:pleme-io/blackmatter-shell";

# configuration.nix or home.nix
imports = [ inputs.blackmatter-shell.homeManagerModules.default ];

blackmatter.components.shell.enable = true;
```

The module generates `~/.zshenv`, `~/.zshrc`, `~/.bashrc`, and `~/.direnvrc` with all plugins, groups, and tools configured.

### Overlay

```nix
nixpkgs.overlays = [ blackmatter-shell.overlays.default ];
# Provides: pkgs.blzsh
```

## Plugins

All plugins are fetched at build time via `builtins.fetchGit` or nixpkgs — no runtime downloads.

| Plugin | Priority | Description |
|--------|----------|-------------|
| fzf | 30 | Fuzzy finder with keybindings and completion |
| fzf-tab | 35 | Replace zsh completion menu with fzf |
| zoxide | 40 | Smart `cd` that learns your habits |
| zsh-autosuggestions | 80 | Fish-like inline suggestions (deferred) |
| direnv | 90 | Per-directory environments with nix-direnv (deferred) |
| zsh-syntax-highlighting | 90 | Command syntax highlighting (deferred) |
| starship | 95 | Cross-shell prompt with Nord theme (deferred) |

Plugins at priority 80+ are deferred — they load after the first prompt paints for faster perceived startup.

## Groups

Five functional groups organize shell configuration:

| Group | Contents |
|-------|----------|
| **common** | History (1B entries), directory options, globbing, Nord palette |
| **completion** | Fuzzy matching, Nord-themed menu, hostname/process completion |
| **editor** | Vi mode, cursor shape, history navigation, clipboard |
| **aliases** | 100+ aliases — git, nix, docker, k8s, Rust tool replacements |
| **functions** | 40+ autoload functions — file ops, search, git, network, dev |

## Bundled Tools

35 CLI tools included with every install. Most are Rust replacements for classic Unix commands.

### Core Replacements

| Tool | Replaces | Purpose |
|------|----------|---------|
| bat | cat | Syntax highlighting, line numbers |
| eza | ls | Icons, git integration, tree view |
| fd | find | Faster, simpler syntax |
| ripgrep | grep | Blazing fast regex search |
| zoxide | cd | Smart directory jumping |
| fzf | — | Fuzzy finder (Go) |
| delta | diff | Side-by-side git diffs |
| dust | du | Disk usage analyzer |
| procs | ps | Modern process viewer |
| bottom | top/htop | System monitor (btm) |
| sd | sed | Intuitive find & replace |
| choose | cut/awk | Human-friendly field selection |

### Data & Text

| Tool | Replaces | Purpose |
|------|----------|---------|
| jaq | jq | JSON processor (Rust, mostly jq-compatible) |
| hexyl | xxd | Hex viewer with colors |
| mdcat | — | Markdown renderer for terminal |
| tokei | cloc | Lines of code counter |
| grex | — | Generate regex from test cases |
| xh | curl/httpie | Friendly HTTP client |

### Files & Archives

| Tool | Replaces | Purpose |
|------|----------|---------|
| ouch | tar/gzip/zip | Universal compress and decompress |
| yazi | ranger/nnn | Terminal file manager |
| miniserve | python -m http.server | Serve directories over HTTP |

### System & Network

| Tool | Replaces | Purpose |
|------|----------|---------|
| bandwhich | nethogs | Network bandwidth by process |
| trippy | traceroute/mtr | Network path diagnostics |
| gping | ping | Graphical ping with chart |
| macchina | neofetch | Fast system info display |
| hyperfine | time | Command benchmarking |

### Development

| Tool | Replaces | Purpose |
|------|----------|---------|
| just | make | Project command runner |
| watchexec | inotifywait | Run commands on file changes |
| difftastic | diff | Syntax-aware structural diff |
| onefetch | — | Git repository summary |
| pastel | — | Color manipulation and conversion |
| vivid | dircolors | LS_COLORS generator with themes |

### Infrastructure

| Tool | Purpose |
|------|---------|
| direnv | Per-directory environments (Go) |
| starship | Cross-shell prompt with Nord theme |
| tealdeer | Fast tldr pages (simplified man) |

## Autoload Functions

All functions in `module/groups/functions/autoload/` are autoloaded on first call:

**File ops:** `mkcd`, `extract`, `compress`, `backup`, `dirsize`
**Search:** `ff`, `grepc`, `fcd`, `fvim`, `fkill`, `fco`
**Git:** `gac`, `gacp`, `gcl`, `gct`, `git-clean-branches`, `git-tree`
**Network:** `myip`, `localip`, `pingweb`, `serve`
**Dev:** `json`, `b64encode`, `b64decode`, `urlencode`, `urldecode`, `calc`, `bench`
**Nix:** `nix-info`, `nix-shell-pkg`
**Docker:** `docker-clean`, `docker-rm-all`, `docker-stop-all`
**K8s:** `klog`, `kexec`
**Misc:** `genpass`, `histstat`, `killport`, `weather`

## Architecture

```
blackmatter-shell/
├── flake.nix               # Flake outputs: packages, homeManagerModules, devShells
├── package.nix             # blzsh standalone binary (embedded store paths)
├── lib/
│   └── shell-helper.nix    # Plugin init generator (priority sort, source commands)
└── module/
    ├── default.nix          # Home Manager module (zshenv/zshrc/bashrc generation)
    ├── plugins/
    │   ├── registry.nix     # Plugin auto-discovery and option generation
    │   ├── direnv/direnv/   # Directory environments
    │   ├── junegunn/fzf/    # Fuzzy finder
    │   ├── aloxaf/fzf-tab/  # fzf-powered completion
    │   ├── ajeetdsouza/zoxide/  # Smart cd
    │   ├── zsh-users/zsh-autosuggestions/
    │   ├── zsh-users/zsh-syntax-highlighting/
    │   └── starship/starship/   # Prompt (includes starship.toml)
    ├── groups/
    │   ├── common/          # Core settings (history, globbing, colors)
    │   ├── completion/      # Zsh completion system
    │   ├── editor/          # Vi mode, EDITOR/VISUAL
    │   ├── aliases/         # 100+ aliases with conditional blnvim support
    │   └── functions/       # 40+ autoload functions
    ├── packages/            # Optional language/ecosystem package sets
    ├── tools/               # Additional shell tools
    ├── background/          # Background job management
    ├── envrc/               # Direnv .envrc deployment
    └── tmux/                # Tmux configuration (platform-specific)
```

## Two Build Modes

### Standalone (`blzsh`)

`package.nix` builds a wrapper script that:
1. Sets `ZDOTDIR` to a Nix store directory containing `.zshenv` and `.zshrc`
2. Sets `DIRENV_CONFIG` for nix-direnv integration
3. Prefixes `PATH` with all bundled tools
4. Execs `zsh`

All file paths in the generated zshrc are absolute Nix store paths — no `$HOME` references needed.

### Home Manager module

`module/default.nix` generates:
- `~/.zshenv` — PATH initialization, home-manager session vars, STARSHIP_CONFIG
- `~/.zshrc` — Settings, completion, plugins (priority-sorted), groups, local.d overrides
- `~/.bashrc` — Minimal bash config for tool compatibility (Claude Code, scripts)
- `~/.bash_profile` — Sources .bashrc in login shells
- `~/.direnvrc` — nix-direnv with PATH-preservation wrapper

Plugin sources are symlinked to `~/.local/share/shell/plugins/` and configs to `~/.config/shell/plugins/`.

## Local Overrides

Both build modes source `~/.config/shell/local.d/*.zsh` at the end of `.zshrc`. This is the intended extension point for machine-specific aliases, environment variables, and tweaks. Each component (e.g., home-manager modules) can drop its own named file here without conflicts.

## Optional Package Sets

The `module/packages/` directory provides opt-in language and ecosystem package collections. Enable them in your home-manager config:

```nix
blackmatter.components.shell.packages = {
  enable = true;
  # Language-specific: golang, rust, python, javascript, lua, ruby, php, etc.
  # Ecosystem: cloud-infrastructure, web-development, systems-programming, devops-automation
};
```

## Platforms

| Platform | Status |
|----------|--------|
| aarch64-darwin | Primary development platform |
| x86_64-darwin | Supported |
| aarch64-linux | Supported |
| x86_64-linux | Supported (includes gitui) |

## Development

```bash
# Enter dev shell (requires direnv or manual activation)
nix develop

# Or run blzsh directly
nix run .#blzsh

# Check shell scripts
shellcheck module/groups/**/*.zsh
shfmt -d module/groups/**/*.zsh
```

## Adding a Plugin

1. Create plugin directory: `module/plugins/<author>/<name>/`
2. Add `default.nix` with the plugin declaration:

```nix
{
  author = "<author>";
  name = "<name>";
  source = {
    type = "github";
    repo = "<author>/<name>";
    ref = "main";
    rev = "<commit-hash>";
  };
  configDir = ./config;
  load = { enable = true; priority = 50; initFile = "init.zsh"; };
}
```

3. Create `config/init.zsh` to source the plugin
4. The registry auto-discovers it — no manual registration needed
5. Enable in your config: `blackmatter.components.shell.plugins.<author>.<name>.enable = true`
6. For the standalone binary, also add the source and init to `package.nix`

## License

MIT
