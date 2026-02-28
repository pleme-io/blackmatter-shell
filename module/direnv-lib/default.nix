# Direnv Library — custom use_* functions for direnv
#
# Files placed in ~/.config/direnv/lib/ are automatically sourced by direnv
# before processing any .envrc file. This provides custom functions like
# use_tend and use_workspace to all projects.
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.shell.direnvLib;
in {
  options.blackmatter.components.shell.direnvLib = {
    enable = mkEnableOption "blackmatter direnv library (custom use_* functions)";
  };

  config = mkIf cfg.enable {
    # direnv auto-sources all .sh files in ~/.config/direnv/lib/
    home.file.".config/direnv/lib/tend.sh".source = ./tend.sh;
    home.file.".config/direnv/lib/workspace.sh".source = ./workspace.sh;
  };
}
