{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.shell.packages;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
in {
  imports = [
    ./ecosystems  # New ecosystem-based organization
  ];
  
  # Package lists (not modules) organized by category
  
  options = {
    blackmatter = {
      components = {
        shell.packages = {
          enable = mkEnableOption "shell.packages";
          arduino.enable = mkEnableOption "arduino packages";
          asm.enable = mkEnableOption "assembly packages";
          aws.enable = mkEnableOption "AWS packages";
          cpp.enable = mkEnableOption "C/C++ packages";
          golang.enable = mkEnableOption "Go packages";
          hashicorp.enable = mkEnableOption "HashiCorp packages";
          javascript.enable = mkEnableOption "JavaScript packages";
          kubernetes.enable = mkEnableOption "Kubernetes packages";
          lua.enable = mkEnableOption "Lua packages";
          nix.enable = mkEnableOption "Nix packages";
          php.enable = mkEnableOption "PHP packages";
          python.enable = mkEnableOption "Python packages";
          redis.enable = mkEnableOption "Redis packages";
          ruby.enable = mkEnableOption "Ruby packages";
          rustlang.enable = mkEnableOption "Rust packages";
          secrets.enable = mkEnableOption "Secret management packages";
          shell.enable = mkEnableOption "Shell utility packages";
          utilities.enable = mkEnableOption "General utility packages";
        };
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs;
        [
          # Core tools (both platforms)
          ripgrep
          claude-code

          # Essential LSP servers (for Claude Code integration)
          # These are always available regardless of language-specific package options
          rust-analyzer                             # Rust LSP
          nodePackages.typescript-language-server   # TypeScript/JavaScript LSP
          nodePackages.typescript                   # Required by TS LSP
          pyright                                   # Python LSP
          nixd                                      # Nix LSP
          gopls                                     # Go LSP
          lua-language-server                       # Lua LSP
        ]
        ++ lib.optionals isDarwin []
        ++ lib.optionals isLinux [
          # python313Packages.huggingface-hub  # Disabled: mypy incompatible with python3.13
          nix-prefetch-git
          attic-client
          openconnect
          traceroute
          llama-cpp
          gnumake
          # awscli2 # Disabled: slow test suite hangs builds
          lazygit
          bundix
          zoxide
          delta
          cargo
          arion
          sops
          xsel
          nmap
          tree
          mpv
          dig
          fzf
          tor
          gh
        ];
    })
    
    # Individual package categories
    (mkIf cfg.arduino.enable {
      home.packages = import ./arduino pkgs;
    })
    (mkIf cfg.asm.enable {
      home.packages = import ./asm pkgs;
    })
    (mkIf cfg.aws.enable {
      home.packages = import ./aws pkgs;
    })
    (mkIf cfg.cpp.enable {
      home.packages = import ./cpp pkgs;
    })
    (mkIf cfg.golang.enable {
      home.packages = import ./golang pkgs;
    })
    (mkIf cfg.hashicorp.enable {
      home.packages = import ./hashicorp pkgs;
    })
    (mkIf cfg.javascript.enable {
      home.packages = import ./javascript pkgs;
    })
    (mkIf cfg.kubernetes.enable {
      home.packages = import ./kubernetes pkgs;
    })
    (mkIf cfg.lua.enable {
      home.packages = import ./lua pkgs;
    })
    (mkIf cfg.nix.enable {
      home.packages = import ./nix pkgs;
    })
    (mkIf cfg.php.enable {
      home.packages = import ./php pkgs;
    })
    (mkIf cfg.python.enable {
      home.packages = import ./python pkgs;
    })
    (mkIf cfg.redis.enable {
      home.packages = import ./redis pkgs;
    })
    (mkIf cfg.ruby.enable {
      home.packages = import ./ruby pkgs;
    })
    (mkIf cfg.rustlang.enable {
      home.packages = import ./rustlang pkgs;
    })
    (mkIf cfg.secrets.enable {
      home.packages = import ./secrets pkgs;
    })
    (mkIf cfg.shell.enable {
      home.packages = import ./shell pkgs;
    })
    (mkIf cfg.utilities.enable {
      home.packages = import ./utilities pkgs;
    })
  ];
}
