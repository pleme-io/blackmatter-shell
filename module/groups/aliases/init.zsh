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

# ls wrapper: Rust binary translates POSIX flags (-ltra) to eza equivalents
alias ls='blx-ls'

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

# Phase 7 Rust tools
alias calc='fend'
alias rga='ripgrep-all'
alias tspin='tailspin'
alias csv='csvlens'
alias changelog='git-cliff'
alias spellcheck='typos'
alias cleanup='kondo'
alias br='broot'
alias loadtest='oha'

# Rust fuzzy selectors (skim-tab binaries)
alias fvim='skim-fvim'
alias fco='skim-fco'
alias fkill='skim-fkill'

# Rust tool wrappers (replace autoload functions)
alias bench='hyperfine'
alias compress='ouch compress'
alias extract='ouch decompress'
alias duh='dust -d 1'
alias grepc='rg -C 3'
alias histstat='atuin stats'
alias ff='fd --type f --hidden --follow --exclude .git'
alias fdir='fd --type d --hidden --follow --exclude .git'
alias serve='miniserve --index index.html'
alias myip='curl -s https://api.ipify.org && echo'
alias b64encode='base64'
alias b64decode='base64 -d'
alias pingweb='curl -o /dev/null -s -w "Response time: %{time_total}s\n"'

# Rust utility binaries (skim-tab crate)
alias kexec='kubectl exec -it $(skim-kpod) -- /bin/bash'
alias klog='kubectl logs -f $(skim-kpod)'

# Docker management
alias docker-clean='docker container prune -f && docker image prune -f && docker volume prune -f && docker network prune -f'
alias docker-rm-all='docker rm $(docker ps -a -q)'
alias docker-stop-all='docker stop $(docker ps -q)'

# Rust utility binaries (skim-tab crate — replace shell functions)
alias gac='git-ac'
alias gacp='git-acp'
alias gct='git-ct'
alias backup='blx-backup'
alias weather='blx-weather'
alias json='blx-json'
alias urlencode='blx-urlencode'
alias urldecode='blx-urldecode'

# Shell functions (require calling shell — cannot be Rust)
nix-shell-pkg() { nix-shell -p "$@" --run zsh; }
nix-info() { nix search nixpkgs "$1" --json | jaq -r '.[] | "\(.pname) (\(.version))\n  \(.description)\n"'; }
gcl()  { git clone "$1" && cd "$(basename "$1" .git)"; }
mkcd() { mkdir -p "$1" && cd "$1"; }

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
# nrb alias injected at Nix build time (platform-specific)

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

# ===== UTILITY =====
alias reload='source ${ZDOTDIR:-$HOME}/.zshrc'
alias path='echo ${(F)path}'
# ports, clipboard, safety aliases injected at Nix build time (platform-specific)

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

# systemctl aliases injected at Nix build time (Linux only)
