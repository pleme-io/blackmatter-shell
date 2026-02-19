{
  pkgs,
  lib,
  blackmatter-nvim,
}: let
  blnvim = blackmatter-nvim.packages.${pkgs.system}.blnvim;
  # GitHub plugin sources (same revs as plugin declarations in registry)
  fzfTabSrc = fetchGit {
    url = "https://github.com/Aloxaf/fzf-tab";
    rev = "01dad759c4466600b639b442ca24aebd5178e799";
  };
  zshAutosuggSrc = fetchGit {
    url = "https://github.com/zsh-users/zsh-autosuggestions";
    rev = "c3d4e576c9c86eac62884bd47c01f6faed043fc5";
  };
  zshSynHlSrc = fetchGit {
    url = "https://github.com/zsh-users/zsh-syntax-highlighting";
    rev = "e0165eaa730dd0fa321a6a6de74f092fe87630b0";
  };

  # Patch each GitHub plugin's init.zsh: replace $HOME path with store path
  fzfTabConfig =
    pkgs.runCommand "fzf-tab-config"
    {
      src = ./module/plugins/aloxaf/fzf-tab/config;
      inherit fzfTabSrc;
    }
    ''
      cp -r $src $out && chmod -R u+w $out
      substituteInPlace $out/init.zsh \
        --replace '$HOME/.local/share/shell/plugins/aloxaf/fzf-tab' "$fzfTabSrc"
    '';

  zshAutosuggConfig =
    pkgs.runCommand "zsh-autosuggestions-config"
    {
      src = ./module/plugins/zsh-users/zsh-autosuggestions/config;
      inherit zshAutosuggSrc;
    }
    ''
      cp -r $src $out && chmod -R u+w $out
      substituteInPlace $out/init.zsh \
        --replace '$HOME/.local/share/shell/plugins/zsh-users/zsh-autosuggestions' "$zshAutosuggSrc"
    '';

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

  # All tools bundled with blzsh
  toolsPath = lib.makeBinPath (with pkgs;
    [
      bat
      eza
      fd
      ripgrep
      zoxide
      fzf
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
      just
      watchexec
      miniserve
      yazi
      direnv
      nix-direnv
      starship
      zsh
      blnvim
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
    if [[ -f "$HOME/.local/state/nix/profiles/home-manager/home-path/etc/profile.d/hm-session-vars.sh" ]]; then
      source "$HOME/.local/state/nix/profiles/home-manager/home-path/etc/profile.d/hm-session-vars.sh"
    elif [[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
      source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    fi
    export STARSHIP_CONFIG="${./module/plugins/starship/starship/config/starship.toml}"
    mkdir -p "''${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
    mkdir -p "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
  '';

  # .zshrc: all file paths are nix store paths embedded at build time
  # functions/init.zsh is NOT sourced (it hardcodes $HOME fpath); inlined below with store path
  zshrc = pkgs.writeText "blzsh-zshrc" ''
    [[ -n "$ZPROF" ]] && zmodload zsh/zprof
    source ${./module/groups/common/settings.zsh}
    source ${./module/groups/completion/init.zsh}
    # Immediate plugins (priority order: lower = earlier)
    # fzf (30): source keybindings directly from nix store — no runtime path resolution needed
    source ${pkgs.fzf}/share/fzf/key-bindings.zsh
    source ${pkgs.fzf}/share/fzf/completion.zsh
    export _BLZSH_FZF_KEYS_LOADED=1
    source ${./module/plugins/junegunn/fzf/config/init.zsh}           # fzf opts + Ctrl+F widget
    source ${fzfTabConfig}/init.zsh                                     # fzf-tab (35)
    source ${./module/plugins/ajeetdsouza/zoxide/config/init.zsh}      # zoxide (40)
    source ${./module/plugins/direnv/direnv/config/init.zsh}           # direnv (90)
    # Deferred plugins (loaded after first prompt paint)
    __blackmatter_deferred() {
      add-zsh-hook -d precmd __blackmatter_deferred
      unfunction __blackmatter_deferred
      source ${zshAutosuggConfig}/init.zsh
      source ${zshSynHlConfig}/init.zsh
      source ${./module/plugins/starship/starship/config/init.zsh}
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd __blackmatter_deferred
    source ${./module/groups/editor/init.zsh}
    source ${./module/groups/aliases/init.zsh}
    # Functions: inline fpath with store path (replaces functions/init.zsh which hardcodes $HOME)
    # Store path is immutable — auto-discover all functions, no manual list needed
    local fn_dir="${./module/groups/functions/autoload}"
    if [[ -d "$fn_dir" ]]; then
      fpath=("$fn_dir" ''${fpath[@]})
      autoload -Uz $fn_dir/*(:t)
    fi
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
  pkgs.writeShellScriptBin "blzsh" ''
    export ZDOTDIR="${zdotdir}"
    export DIRENV_CONFIG="${direnvConfigDir}"
    export PATH="${toolsPath}:$PATH"
    exec ${pkgs.zsh}/bin/zsh "$@"
  ''
