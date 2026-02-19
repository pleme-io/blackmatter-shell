{
  author = "starship";
  name = "starship";
  source = {
    type = "nixpkgs";
    package = "starship"; # Uses pkgs.starship from nixpkgs
  };
  configDir = ./config;
  load = {
    enable = true;
    priority = 95; # Load very late (prompt should be initialized last)
    initFile = "init.zsh";
  };
}
