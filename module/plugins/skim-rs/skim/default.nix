{
  author = "skim-rs";
  name = "skim";
  source = {
    type = "nixpkgs";
    package = "skim"; # Uses pkgs.skim from nixpkgs
  };
  configDir = ./config;
  load = {
    enable = true;
    priority = 30; # Load early for keybindings
    initFile = "init.zsh";
  };
}
