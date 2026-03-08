# Shell Aliases — blzsh curated distribution
# All tools are guaranteed in PATH via package.nix. No guards needed.

# ===== EDITOR =====
alias vim='blnvim'
alias vi='blnvim'
alias nvim='blnvim'
alias vimdiff='blnvim -d'

# ===== RUST POWER TOOLS =====
# Drop-in replacements where flag syntax is compatible.
# Tools with incompatible flags (fd, rg, sd, difft) keep their own names.

# bat → cat
alias cat='bat --style=plain --paging=never'
alias catt='bat'

# eza → ls family
alias l='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza -T --icons --group-directories-first'
alias lta='eza -la --sort=modified --reverse --icons --group-directories-first'
alias ltr='eza -l --sort=modified --reverse --icons --group-directories-first'
alias tree='eza --tree --icons'

# ls wrapper: translates packed POSIX flags (-ltra) to eza equivalents
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

# bottom → top/htop
alias top='btm'
alias htop='btm'

# Short names for Rust tools
alias loc='tokei'
alias http='xh'
alias https='xh --https'
alias hex='hexyl'
alias sysinfo='macchina'
alias neofetch='macchina'
alias mcat='mdcat'
alias fm='yazi'

# Git TUI
alias lg='lazygit'
alias gg='lazygit'

# ===== NAVIGATION =====
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# ===== GIT =====
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gds='git diff --staged'
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

# ===== NIX =====
alias nix='noglob nix'
alias nix-shell='noglob nix-shell --run zsh'
alias nb='noglob nix build'
alias nd='noglob nix develop'
alias ns='noglob nix search nixpkgs'
alias nfu='noglob nix flake update'
alias ngc='noglob nix-collect-garbage -d'
if [[ "$(uname)" == "Darwin" ]]; then
  alias nrb='noglob darwin-rebuild switch --flake .'
else
  alias nrb='noglob sudo nixos-rebuild switch --flake .'
fi

# ===== KUBERNETES =====
alias kgd='kubectl get deployments'
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kl='kubectl logs'
alias klf='kubectl logs -f'

# ===== DOCKER =====
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dl='docker logs'
alias dlf='docker logs -f'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcd='docker compose down'

# ===== FILE OPERATIONS =====
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias df='df -h'

# ===== CLIPBOARD (Linux only — macOS has pbcopy/pbpaste natively) =====
if [[ "$(uname)" == "Linux" ]]; then
  if [[ -n "$WAYLAND_DISPLAY" ]]; then
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
  elif [[ -n "$DISPLAY" ]]; then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
  fi
fi

# ===== UTILITY =====
alias reload='source ${ZDOTDIR:-$HOME}/.zshrc'
alias path='echo ${(F)path}'
if [[ "$(uname)" == "Darwin" ]]; then
  alias ports='lsof -i -n -P | grep LISTEN'
else
  alias ports='ss -tulanp'
fi

# Safety aliases (GNU coreutils only)
if [[ "$(uname)" != "Darwin" ]]; then
  alias chown='chown --preserve-root'
  alias chmod='chmod --preserve-root'
  alias chgrp='chgrp --preserve-root'
fi

# blzsh config is in the Nix store — edit the source repo
alias shellrc='vim ~/code/github/pleme-io/blackmatter-shell/'

# ===== DEVELOPMENT =====
alias py='python3'
alias python='python3'

# Rust/cargo
alias cr='cargo run'
alias ct='cargo test'
alias cb='cargo build'
alias cbr='cargo build --release'
alias cc='cargo check'
alias cl='cargo clippy'
alias cf='cargo fmt'
alias cu='cargo update'

# ===== SUDO =====
alias please='sudo'
alias pls='sudo'

# ===== SYSTEMCTL (Linux) =====
if command -v systemctl &> /dev/null; then
  alias sc='sudo systemctl'
  alias scs='sudo systemctl status'
  alias scr='sudo systemctl restart'
  alias sce='sudo systemctl enable'
  alias scd='sudo systemctl disable'
  alias scst='sudo systemctl start'
  alias scsp='sudo systemctl stop'
fi
