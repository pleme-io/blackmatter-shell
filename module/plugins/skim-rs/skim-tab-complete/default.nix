{
  author = "skim-rs";
  name = "skim-tab-complete";
  source = {
    type = "nixpkgs";
    package = "skim-tab"; # Uses skim-tab from overlay
  };
  configDir = ./config;
  load = {
    enable = true;
    priority = 35; # After skim (30), before zoxide (40)
    initFile = "init.zsh";
  };
}
