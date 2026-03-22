{
  pkgs,
  lib,
  blackmatter-nvim,
  skim-tab,
  blx,
  bm-guard,
}: let
  blnvim = blackmatter-nvim.packages.${pkgs.system}.blnvim;
  skimTabBin = skim-tab.packages.${pkgs.system}.default;
  bmGuardBin = bm-guard.packages.${pkgs.system}.default;
  blxBin = pkgs.symlinkJoin {
    name = "blx-with-multicall";
    paths = [ blx.packages.${pkgs.system}.default ];
    postBuild = ''
      cd $out/bin
      for name in blx-ls blx-backup blx-weather blx-json \
                  blx-urlencode blx-urldecode \
                  blx-preview blx-preview-dir blx-preview-proc blx-preview-git; do
        ln -sf blx "$name"
      done
    '';
  };
  # GitHub plugin sources (same revs as plugin declarations in registry)
  zshSynHlSrc = fetchGit {
    url = "https://github.com/zsh-users/zsh-syntax-highlighting";
    rev = "e0165eaa730dd0fa321a6a6de74f092fe87630b0";
  };

  zshSynHlConfig =
    pkgs.runCommand "zsh-syntax-highlighting-config"
    {
      src = ./module/plugins/zsh-users/zsh-syntax-highlighting/config;
      inherit zshSynHlSrc;
    }
    ''
      cp -r $src $out && chmod -R u+w $out
      substituteInPlace $out/init.zsh \
        --replace '$HOME/.local/share/shell/plugins/zsh-users/zsh-syntax-highlighting' "$zshSynHlSrc"
    '';

  # Bake Nord LS_COLORS at build time (no runtime vivid call needed)
  nordLsColors = builtins.readFile (pkgs.runCommand "nord-ls-colors" {} ''
    ${pkgs.vivid}/bin/vivid generate nord | tr -d '\n' > $out
  '');

  # Direnv config: nix-direnv integration + PATH-preservation wrapper
  direnvrc = pkgs.writeText "direnvrc" ''
    source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
    if declare -f use_flake > /dev/null; then
      eval "$(declare -f use_flake | sed '1s/use_flake/_use_flake_nixdirenv/')"
      use_flake() {
        local saved_path="$PATH"
        _use_flake_nixdirenv "$@"
        export PATH="$PATH:$saved_path"
      }
    fi
  '';

  direnvConfigDir = pkgs.runCommand "blzsh-direnv-config" {} ''
    mkdir $out && ln -s ${direnvrc} $out/direnvrc
  '';

  # Platform-specific aliases baked at build time (no runtime uname checks)
  platformAliases = pkgs.writeText "blzsh-platform-aliases" (
    lib.optionalString pkgs.stdenv.isDarwin ''
      alias nrb='noglob darwin-rebuild switch --flake .'
      alias ports='lsof -i -n -P | grep LISTEN'
    ''
    + lib.optionalString pkgs.stdenv.isLinux ''
      alias nrb='noglob sudo nixos-rebuild switch --flake .'
      alias ports='ss -tulanp'
      if [[ -n "$WAYLAND_DISPLAY" ]]; then
        alias pbcopy='wl-copy'
        alias pbpaste='wl-paste'
      elif [[ -n "$DISPLAY" ]]; then
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'
      fi
      alias chown='chown --preserve-root'
      alias chmod='chmod --preserve-root'
      alias chgrp='chgrp --preserve-root'
      alias sc='sudo systemctl'
      alias scs='sudo systemctl status'
      alias scr='sudo systemctl restart'
      alias sce='sudo systemctl enable'
      alias scd='sudo systemctl disable'
      alias scst='sudo systemctl start'
      alias scsp='sudo systemctl stop'
    ''
  );

  # All tools bundled with blzsh
  toolsPath = lib.makeBinPath (with pkgs;
    [
      # ── Core tools (required by aliases, functions, plugins) ──
      coreutils # GNU wc, sort, cut, etc.
      git
      curl
      python3
      openssl

      # ── Rust CLI replacements ──
      bat
      eza
      fd
      ripgrep
      zoxide
      skim
      skimTabBin
      bmGuardBin
      atuin
      delta
      dust
      procs
      bottom
      sd
      tokei
      hyperfine
      tealdeer
      xh
      jaq
      ouch
      hexyl
      choose
      difftastic
      vivid
      mdcat
      pastel
      grex
      macchina
      onefetch
      bandwhich
      trippy
      gping
      oha
      hurl
      just
      watchexec
      miniserve
      yazi
      lazygit
      bacon
      cargo-nextest
      mprocs
      ast-grep
      git-cliff
      sccache
      typos
      csvlens
      htmlq
      fend
      tailspin
      kondo
      broot
      ripgrep-all
      pueue

      # ── Shell infrastructure ──
      direnv
      nix-direnv
      starship
      zsh
      blnvim
      blxBin
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [pkgs.gitui]);

  # .zshenv: load nix, load hm session vars, set STARSHIP_CONFIG, create writable dirs
  zshenv = pkgs.writeText "blzsh-zshenv" ''
    if [ -n "$__BLACKMATTER_ZSHENV_SOURCED" ]; then return; fi
    export __BLACKMATTER_ZSHENV_SOURCED=1
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    # Load home-manager session variables (EDITOR, SOPS_AGE_KEY_FILE, LIBRARY_PATH, etc.)
    # Try: nix-darwin per-user profile → standalone HM → nix-profile fallback
    if [[ -f "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]]; then
      source "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
    elif [[ -f "$HOME/.local/state/nix/profiles/home-manager/home-path/etc/profile.d/hm-session-vars.sh" ]]; then
      source "$HOME/.local/state/nix/profiles/home-manager/home-path/etc/profile.d/hm-session-vars.sh"
    elif [[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
      source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    fi
    export STARSHIP_CONFIG="${./module/plugins/starship/starship/config/starship.toml}"
    export LS_COLORS="${nordLsColors}"
    mkdir -p "''${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
    mkdir -p "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
  '';

  # .zshrc: all file paths are nix store paths embedded at build time
  # functions/init.zsh is NOT sourced (it hardcodes $HOME fpath); inlined below with store path
  zshrc = pkgs.writeText "blzsh-zshrc" ''
    [[ -n "$ZPROF" ]] && zmodload zsh/zprof
    source ${./module/groups/common/settings.zsh}
    # Add zsh-completions to fpath BEFORE compinit (300+ extra _* functions)
    fpath=(${pkgs.zsh-completions}/share/zsh/site-functions $fpath)
    source ${./module/groups/completion/init.zsh}
    # ===== VIM MODE =====
    # Must be set BEFORE plugins so plugin keybindings (atuin ctrl-r, etc.)
    # are not clobbered — bindkey -v resets the viins keymap to defaults.
    bindkey -v

    # Immediate plugins (priority order: lower = earlier)
    # skim (30): source keybindings directly from nix store
    source ${pkgs.skim}/share/skim/key-bindings.zsh
    source ${pkgs.skim}/share/skim/completion.zsh
    export _BLZSH_SKIM_KEYS_LOADED=1
    source ${./module/plugins/skim-rs/skim/config/init.zsh}            # skim opts + Ctrl+F widget
    source ${./module/plugins/skim-rs/skim-tab-complete/config/init.zsh}  # skim-tab-complete (35, native skim)
    source ${./module/plugins/ajeetdsouza/zoxide/config/init.zsh}      # zoxide (40)
    source ${./module/plugins/atuinsh/atuin/config/init.zsh}           # atuin (50, replaces autosuggestions)
    source ${./module/plugins/pleme-io/bm-guard/config/init.zsh}       # bm-guard (55, AFTER atuin so it wraps on top)
    source ${./module/plugins/direnv/direnv/config/init.zsh}           # direnv (90)
    # Deferred plugins (loaded after first prompt paint)
    __blackmatter_deferred() {
      add-zsh-hook -d precmd __blackmatter_deferred
      unfunction __blackmatter_deferred
      source ${zshSynHlConfig}/init.zsh
      source ${./module/plugins/starship/starship/config/init.zsh}
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd __blackmatter_deferred
    source ${./module/groups/editor/init.zsh}
    source ${./module/groups/aliases/init.zsh}
    source ${platformAliases}
    # ===== LOCAL OVERRIDES =====
    # Machine-specific aliases, env vars, tweaks (written by home-manager components)
    # e.g. ssh-aliases.zsh, cid.zsh — each component writes its own named file
    for __bm_local in ~/.config/shell/local.d/*.zsh; do
      [[ -f "$__bm_local" ]] && source "$__bm_local"
    done
    unset __bm_local
    [[ -n "$ZPROF" ]] && zprof
  '';

  # ZDOTDIR: zsh reads .zshenv and .zshrc from this directory
  zdotdir = pkgs.runCommand "blzsh-zdotdir" {} ''
    mkdir $out
    ln -s ${zshenv} $out/.zshenv
    ln -s ${zshrc} $out/.zshrc
  '';
in
  (pkgs.writeShellScriptBin "blzsh" ''
    export ZDOTDIR="${zdotdir}"
    export DIRENV_CONFIG="${direnvConfigDir}"
    export PATH="${toolsPath}:$PATH"
    exec ${pkgs.zsh}/bin/zsh "$@"
  '').overrideAttrs (final: {
    meta = {
      description = "Blackmatter Shell - curated zsh distribution with 7 plugins and 35+ bundled tools";
      homepage = "https://github.com/pleme-io/blackmatter-shell";
      license = lib.licenses.mit;
      mainProgram = "blzsh";
    };
    passthru.shellPath = "/bin/blzsh";
  })
