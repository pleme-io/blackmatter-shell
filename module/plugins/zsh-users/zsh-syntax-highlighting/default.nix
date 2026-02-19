{
  author = "zsh-users";
  name = "zsh-syntax-highlighting";
  source = {
    type = "github";
    repo = "zsh-users/zsh-syntax-highlighting";
    ref = "master";
    rev = "e0165eaa730dd0fa321a6a6de74f092fe87630b0"; # Latest as of 2024
  };
  configDir = ./config;
  load = {
    enable = true;
    priority = 90; # Load last (after all other plugins for accurate highlighting)
    initFile = "init.zsh";
    defer = true; # Load after first prompt paint for faster startup
  };
}
