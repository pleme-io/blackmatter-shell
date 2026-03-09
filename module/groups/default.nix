# Shell Groups - Logical organization of shell functionality
# Similar to nvim groups, but for shell configuration

{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.shell.groups;

  # Platform-specific aliases injected at Nix build time (no runtime uname checks)
  platformAliases =
    lib.optionalString pkgs.stdenv.isDarwin ''
      alias nrb='noglob darwin-rebuild switch --flake .'
      alias ports='lsof -i -n -P | grep LISTEN'
    ''
    + lib.optionalString pkgs.stdenv.isLinux ''
      alias nrb='noglob sudo nixos-rebuild switch --flake .'
      alias ports='ss -tulanp'
      # Clipboard (Wayland preferred, X11 fallback)
      if [[ -n "$WAYLAND_DISPLAY" ]]; then
        alias pbcopy='wl-copy'
        alias pbpaste='wl-paste'
      elif [[ -n "$DISPLAY" ]]; then
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'
      fi
      # GNU coreutils safety
      alias chown='chown --preserve-root'
      alias chmod='chmod --preserve-root'
      alias chgrp='chgrp --preserve-root'
      # systemctl
      alias sc='sudo systemctl'
      alias scs='sudo systemctl status'
      alias scr='sudo systemctl restart'
      alias sce='sudo systemctl enable'
      alias scd='sudo systemctl disable'
      alias scst='sudo systemctl start'
      alias scsp='sudo systemctl stop'
    '';
in {
  options.blackmatter.components.shell.groups = {
    enable = mkEnableOption "enable shell groups";

    common = {
      enable = mkEnableOption "core shell settings (history, options)" // {default = true;};
    };

    completion = {
      enable = mkEnableOption "zsh completion system" // {default = true;};
    };

    editor = {
      enable = mkEnableOption "vim mode and editor integration" // {default = true;};
    };

    aliases = {
      enable = mkEnableOption "common command aliases" // {default = true;};
    };

    functions = {
      enable = mkEnableOption "useful shell functions" // {default = true;};
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Symlink group configs to ~/.config/shell/groups/
    (mkIf cfg.common.enable {
      xdg.configFile."shell/groups/common/settings.zsh".source = ./common/settings.zsh;
    })

    (mkIf cfg.completion.enable {
      xdg.configFile."shell/groups/completion/init.zsh".source = ./completion/init.zsh;
    })

    (mkIf cfg.editor.enable {
      xdg.configFile."shell/groups/editor/init.zsh".source = ./editor/init.zsh;
    })

    (mkIf cfg.aliases.enable {
      xdg.configFile."shell/groups/aliases/init.zsh".text =
        builtins.readFile ./aliases/init.zsh + platformAliases;
    })

    (mkIf cfg.functions.enable {
      xdg.configFile."shell/groups/functions/init.zsh".source = ./functions/init.zsh;
    })
  ]);
}
