# Shell Aliases - Common command aliases

# ===== EDITOR ALIASES =====
# Prefer blnvim (blackmatter neovim) when available, fall back to nvim
if command -v blnvim &> /dev/null; then
  alias vim='blnvim'
  alias vi='blnvim'
  alias nvim='blnvim'
  alias vimdiff='blnvim -d'
else
  alias vim='nvim'
  alias vi='nvim'
  alias vimdiff='nvim -d'
fi

# ===== RUST POWER TOOLS - TRANSPARENT REPLACEMENTS =====
# Modern Rust tools that drop in seamlessly for classic Unix commands

# bat → cat (with fallback)
if command -v bat &> /dev/null; then
  alias cat='bat --style=plain --paging=never'
  alias catt='bat'  # Full bat with syntax highlighting
  alias bathelp='bat --list-themes'
fi

# eza → ls (keeping both styles available)
if command -v eza &> /dev/null; then
  # Modern eza aliases (recommended)
  alias l='eza --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first'
  alias la='eza -la --icons --group-directories-first'
  alias lt='eza -T --icons --group-directories-first'
  alias lta='eza -la --sort=modified --reverse --icons --group-directories-first'  # ls -ltra
  alias ltr='eza -l --sort=modified --reverse --icons --group-directories-first'   # ls -ltr
  alias tree='eza --tree --icons'

  # ls wrapper: translates traditional flags (-ltra, -la, -lt, etc.) to eza equivalents
  # eza can't parse packed flags like -ltra directly (its -t takes a value, not a boolean)
  ls() {
    local -a eza_args=(--icons --group-directories-first)
    local -a paths=()
    local has_l=0 has_a=0 has_t=0 has_r=0 has_1=0
    for arg in "$@"; do
      if [[ "$arg" == --* ]]; then
        eza_args+=("$arg")
      elif [[ "$arg" == -* ]]; then
        [[ "$arg" == *l* ]] && has_l=1
        [[ "$arg" == *[aA]* ]] && has_a=1
        [[ "$arg" == *t* ]] && has_t=1
        [[ "$arg" == *r* ]] && has_r=1
        [[ "$arg" == *1* ]] && has_1=1
      else
        paths+=("$arg")
      fi
    done
    (( has_l )) && eza_args+=("-l")
    (( has_a )) && eza_args+=("-a")
    (( has_t )) && eza_args+=(--sort=modified)
    (( has_r )) && eza_args+=(--reverse)
    (( has_1 )) && eza_args+=("-1")
    eza "${eza_args[@]}" "${paths[@]}"
  }
fi

# fd — use directly as 'fd'; do NOT alias find→fd.
# fd has incompatible flag syntax with POSIX find (no -name, -type f, -exec, etc.),
# which breaks scripts, tools, and IDE integrations that rely on standard find flags.
if command -v fd &> /dev/null; then
  alias fdfind='fd'
fi

# ripgrep - keep traditional grep for compatibility with pipes and common CLI usage
# rg is available directly and much faster, but grep flags differ
if command -v rg &> /dev/null; then
  # Don't alias grep to rg - they have different flag syntax
  # Use 'rg' directly when you want ripgrep's speed
  alias rgrep='rg'
fi

# dust → du (better disk usage)
if command -v dust &> /dev/null; then
  alias du='dust'
  alias duu='dust'  # Explicit dust command
fi

# procs → ps (modern process viewer)
if command -v procs &> /dev/null; then
  alias ps='procs'
  alias pss='procs'  # Explicit procs command
  alias pstree='procs --tree'
fi

# bottom → top/htop (system monitor)
if command -v btm &> /dev/null; then
  alias top='btm'
  alias htop='btm'
  alias btop='btm'
fi

# delta — git uses it automatically via programs.git.delta; no alias needed
# (aliasing diff→delta breaks scripts: different flag syntax)

# sd — keep explicit name only; don't alias sed (different syntax, breaks scripts)
if command -v sd &> /dev/null; then
  alias sdd='sd'
fi

# tokei → code statistics
if command -v tokei &> /dev/null; then
  alias loc='tokei'  # Lines of code
  alias sloc='tokei'
fi

# ===== EXTENDED RUST POWER TOOLS =====

# xh → curl/httpie (friendly HTTP client)
if command -v xh &> /dev/null; then
  alias http='xh'
  alias https='xh --https'
fi

# hexyl → hex viewer
if command -v hexyl &> /dev/null; then
  alias hex='hexyl'
fi

# macchina → neofetch replacement
if command -v macchina &> /dev/null; then
  alias neofetch='macchina'
  alias sysinfo='macchina'
fi

# mdcat → markdown renderer
if command -v mdcat &> /dev/null; then
  alias mcat='mdcat'
fi

# yazi → terminal file manager
if command -v yazi &> /dev/null; then
  alias fm='yazi'
fi

# miniserve → HTTP file server
# Note: 'serve' function in functions/autoload handles the simple case
if command -v miniserve &> /dev/null; then
  alias servedir='miniserve --index index.html'
fi

# ouch → universal compress/decompress
# No alias — use 'ouch compress/decompress/list' directly (different interface from tar)

# jaq → jq clone in Rust (mostly compatible, but don't alias jq to avoid subtle breakage)
# Use 'jaq' directly for speed, 'jq' when compatibility matters

# difftastic → syntax-aware diff
# Use 'difft' directly; don't alias 'diff' (different output format)

# choose → cut/awk replacement
# Use 'choose' directly in pipes; don't alias cut (different syntax)

# grex, pastel, vivid, bandwhich, trippy, gping, onefetch — use directly by name

# zoxide → cd (smart jumping)
# Note: zoxide is initialized via plugin, overrides 'cd' with smart navigation
# Tab completion works seamlessly with zoxide-enhanced cd

# Git TUI tools (cross-platform)
if command -v lazygit &> /dev/null; then
  alias lg='lazygit'
fi

# gitui → git TUI (Linux only, fallback)
if command -v gitui &> /dev/null; then
  alias gitui-tui='gitui'
fi

# ===== NAVIGATION =====
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# ===== GIT ALIASES =====
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'          # Uses delta automatically
alias gds='git diff --staged' # Uses delta automatically
alias gl='git log --oneline --graph --decorate'
alias gla='git log --oneline --graph --decorate --all'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias grb='git rebase'
alias grbi='git rebase -i'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gpf='git push --force-with-lease'
alias gsw='git switch'
alias gswc='git switch -c'
alias gr='git restore'
alias grs='git restore --staged'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'

# Advanced git aliases
alias glazy='lazygit'        # TUI for git (cross-platform)
alias gg='lazygit'           # Quick access to git TUI (works on macOS + Linux)

# ===== NIX ALIASES =====
# Disable globbing for nix commands to allow # in flake URIs
alias nix='noglob nix'
alias nix-shell='noglob nix-shell --run zsh'
alias nix-build='noglob nix build'
alias nix-dev='noglob nix develop'
alias nix-search='noglob nix search nixpkgs'
alias nix-update='noglob nix flake update'
alias nix-clean='noglob nix-collect-garbage -d'
if [[ "$(uname)" == "Darwin" ]]; then
  alias nix-rebuild='noglob darwin-rebuild switch --flake .'
else
  alias nix-rebuild='noglob sudo nixos-rebuild switch --flake .'
fi

# ===== KUBERNETES ALIASES =====
# Note: Basic kubectl aliases are in kubernetes component
# Note: klog and kexec are interactive functions (see functions/init.zsh)
alias kgd='kubectl get deployments'
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kl='kubectl logs'
alias klf='kubectl logs -f'

# ===== DOCKER ALIASES =====
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dex='docker exec -it'
alias dl='docker logs'
alias dlf='docker logs -f'
alias dcp='docker-compose ps'
alias dcu='docker-compose up'
alias dcud='docker-compose up -d'
alias dcd='docker-compose down'
alias dcl='docker-compose logs'
alias dclf='docker-compose logs -f'

# ===== FILE OPERATIONS =====
alias cp='cp -i'      # Confirm before overwriting
alias mv='mv -i'      # Confirm before overwriting
alias rm='rm -i'      # Confirm before removing
alias mkdir='mkdir -p' # Create parent directories as needed
alias df='df -h'      # Human-readable sizes
alias free='free -h'  # Human-readable sizes (Linux only)

# Note: du, ps, top, htop are replaced by Rust tools above (dust, procs, bottom)

# ===== CLIPBOARD (Platform-specific) =====
if command -v uname &> /dev/null && [[ "$(uname)" == "Linux" ]]; then
  # Wayland
  if [[ -n "$WAYLAND_DISPLAY" ]]; then
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
  # X11
  elif [[ -n "$DISPLAY" ]]; then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
  fi
fi

# ===== UTILITY ALIASES =====
alias reload='source ${ZDOTDIR:-$HOME}/.zshrc'
alias path='echo ${(F)path}'    # Pure zsh — no subprocess
if [[ "$(uname)" == "Darwin" ]]; then
  alias ports='lsof -i -n -P | grep LISTEN'
else
  alias ports='ss -tulanp'
fi
alias wget='wget -c'  # Resume downloads by default

# Note: ripgrep (rg) is available but grep remains for compatibility

# ===== SAFETY ALIASES =====
# Prevent accidental destructive operations
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# ===== QUICK EDIT ALIASES =====
alias zshrc='vim ~/.zshrc'
alias vimrc='vim ~/.config/nvim/init.lua'
alias aliases='vim ~/.config/shell/groups/aliases/init.zsh'

# ===== DEVELOPMENT ALIASES =====
alias py='python3'
alias python='python3'
alias pip='pip3'
# Note: serve is a function in functions/init.zsh that accepts a port argument

# Node/npm
alias nr='npm run'
alias nrs='npm run start'
alias nrt='npm run test'
alias nrb='npm run build'
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install --global'

# Rust/cargo
alias cr='cargo run'
alias ct='cargo test'
alias cb='cargo build'
alias cbr='cargo build --release'
alias cc='cargo check'
alias cl='cargo clippy'
alias cf='cargo fmt'
alias cu='cargo update'

# ===== FUN ALIASES =====
alias please='sudo'
alias fucking='sudo'
alias pls='sudo'

# ===== TMUX ALIASES =====
alias ta='tmux attach'
alias tls='tmux ls'
alias tat='tmux attach -t'
alias tns='tmux new-session -s'
alias tks='tmux kill-session -t'

# ===== SYSTEMCTL ALIASES (Linux) =====
if command -v systemctl &> /dev/null; then
  alias sc='sudo systemctl'
  alias scs='sudo systemctl status'
  alias scr='sudo systemctl restart'
  alias sce='sudo systemctl enable'
  alias scd='sudo systemctl disable'
  alias scst='sudo systemctl start'
  alias scsp='sudo systemctl stop'
fi
