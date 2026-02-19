{
  author = "aloxaf";
  name = "fzf-tab";
  source = {
    type = "github";
    repo = "Aloxaf/fzf-tab";
    ref = "master";
    rev = "01dad759c4466600b639b442ca24aebd5178e799"; # v1.2.0
  };
  configDir = ./config;
  load = {
    enable = true;
    priority = 35; # After fzf (30), before zoxide (40) - needs compinit first
    initFile = "init.zsh";
  };
}
