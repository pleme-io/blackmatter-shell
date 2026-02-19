# Shell Plugin Registry - Auto-discovers and registers all shell plugins
# 7 shell enhancement plugins using the simple declaration format
# All managed by Nix: nixpkgs packages or builtins.fetchGit from GitHub

{
  lib,
  pkgs,
  ...
}: let
  shellHelper = import ../../lib/shell-helper.nix {inherit lib pkgs;};

  # All shell plugins using new declaration format
  pluginDecls = [
    (import ./direnv/direnv/default.nix) # Priority 20
    (import ./junegunn/fzf/default.nix) # Priority 30
    (import ./aloxaf/fzf-tab/default.nix) # Priority 35
    (import ./ajeetdsouza/zoxide/default.nix) # Priority 40
    (import ./zsh-users/zsh-autosuggestions/default.nix) # Priority 80 (deferred)
    (import ./zsh-users/zsh-syntax-highlighting/default.nix) # Priority 90 (deferred)
    (import ./starship/starship/default.nix) # Priority 95
  ];

  # Convert declarations to module imports using shell-helper
  pluginModules = map shellHelper.mkPlugin pluginDecls;
in {
  # Import all 7 shell plugin modules
  imports = pluginModules;
}
