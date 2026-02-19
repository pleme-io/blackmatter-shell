{
  author = "ajeetdsouza";
  name = "zoxide";
  source = {
    type = "nixpkgs";
    package = "zoxide"; # Uses pkgs.zoxide from nixpkgs
  };
  configDir = ./config;
  load = {
    enable = true;
    priority = 40; # Load after fzf
    initFile = "init.zsh";
  };
}
