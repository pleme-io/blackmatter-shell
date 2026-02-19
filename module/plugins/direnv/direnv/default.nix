{
  author = "direnv";
  name = "direnv";
  source = {
    type = "nixpkgs";
    package = "direnv"; # Uses pkgs.direnv from nixpkgs
  };
  configDir = ./config;
  load = {
    enable = true;
    priority = 90; # Load late (after PATH and environment are fully set up)
    initFile = "init.zsh";
  };
}
