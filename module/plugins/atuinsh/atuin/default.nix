{
  author = "atuinsh";
  name = "atuin";
  source = {
    type = "nixpkgs";
    package = "atuin"; # Uses pkgs.atuin from nixpkgs
  };
  configDir = ./config;
  load = {
    enable = true;
    priority = 50; # After skim (30) and fzf-tab (35), before direnv (90)
    initFile = "init.zsh";
  };
}
