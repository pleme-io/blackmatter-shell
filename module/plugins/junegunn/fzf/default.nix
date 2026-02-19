{
  author = "junegunn";
  name = "fzf";
  source = {
    type = "nixpkgs";
    package = "fzf"; # Uses pkgs.fzf from nixpkgs
  };
  configDir = ./config;
  load = {
    enable = true;
    priority = 30; # Load early for keybindings
    initFile = "init.zsh";
  };
}
