# Shell Groups - Logical organization of shell functionality
# Similar to nvim groups, but for shell configuration

{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.shell.groups;
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
      xdg.configFile."shell/groups/aliases/init.zsh".source = ./aliases/init.zsh;
    })

    (mkIf cfg.functions.enable {
      xdg.configFile."shell/groups/functions/init.zsh".source = ./functions/init.zsh;
      xdg.configFile."shell/groups/functions/autoload" = {
        source = ./functions/autoload;
        recursive = true;
      };
    })
  ]);
}
