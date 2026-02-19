# Completion System - Advanced zsh completion with cached compinit

# XDG-compliant cache directory
local _zsh_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$_zsh_cache" ]] || mkdir -p "$_zsh_cache"

# Initialize completion system with dump caching
# Only regenerate the dump file once per day for fast startup
autoload -Uz compinit
local zcompdump="$_zsh_cache/zcompdump-$HOST"
if [[ -n ${zcompdump}(#qN.mh+24) ]] || [[ ! -f "$zcompdump" ]]; then
  compinit -d "$zcompdump"
else
  compinit -C -d "$zcompdump"
fi
# Compile dump file in background for faster loading
{ [[ ! ${zcompdump}.zwc -nt ${zcompdump} ]] && zcompile "${zcompdump}" } &!

# Cache completion results
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$_zsh_cache"

# ===== COMPLETION MATCHING =====
# Case-insensitive (all), partial-word, and substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# ===== COMPLETION MENU =====
# Group matches and describe
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# ===== COMPLETION COLORS (Nord theme) =====
# Use LS_COLORS for file completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# ===== FUZZY MATCHING =====
# Allow one error for every three characters typed in approximate completer
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'

# ===== DIRECTORY COMPLETION =====
# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

# ... unless we really want to
zstyle '*' single-ignored show

# ===== PROCESS COMPLETION =====
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single

# ===== HOSTNAME COMPLETION =====
# Don't complete uninteresting hostnames
zstyle ':completion:*:ssh:*' hosts off
zstyle ':completion:*:scp:*' hosts off

# ===== COMMAND COMPLETION =====
# Ignore completion functions for commands you don't have
zstyle ':completion:*:functions' ignored-patterns '_*'

# Array completion element sorting
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# ===== CD COMPLETION =====
# cd will never select the parent directory
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*' special-dirs true

# ===== PERFORMANCE =====
# Speedup path completion
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' accept-exact-dirs true

# Separate man page sections
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.*' insert-sections true

# ===== REHASH =====
# Automatically find new executables in path
zstyle ':completion:*' rehash true
