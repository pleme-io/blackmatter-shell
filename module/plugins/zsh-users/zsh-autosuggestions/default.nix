{
  author = "zsh-users";
  name = "zsh-autosuggestions";
  source = {
    type = "github";
    repo = "zsh-users/zsh-autosuggestions";
    ref = "master";
    rev = "c3d4e576c9c86eac62884bd47c01f6faed043fc5"; # v0.7.0
  };
  configDir = ./config;
  load = {
    enable = true;
    priority = 80; # Load after completion, before prompt
    initFile = "init.zsh";
    defer = true; # Load after first prompt paint for faster startup
  };
}
