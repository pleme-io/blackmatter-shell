{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.shell.packages.ecosystems.systemsProgramming;

  # Platform detection
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  # Platform-specific C/C++ compiler
  # macOS: clang (native toolchain)
  # Linux: gcc (standard toolchain)
  cppCompiler = if isDarwin then pkgs.clang else pkgs.gcc;
in {
  options = {
    blackmatter = {
      components = {
        shell.packages.ecosystems.systemsProgramming = {
          enable = mkEnableOption "systems programming ecosystem";
          
          rust = {
            enable = mkEnableOption "Rust toolchain and tools";
            enableDev = mkEnableOption "Rust development tools";
            enableUtilities = mkEnableOption "Rust-based utilities";
          };
          
          go = {
            enable = mkEnableOption "Go toolchain and tools";
            enableDev = mkEnableOption "Go development tools";
          };
          
          cpp = {
            enable = mkEnableOption "C++ development tools";
          };
          
          assembly = {
            enable = mkEnableOption "Assembly development tools";
          };
          
          # Quick overlay for systems programming
          enableFullStack = mkEnableOption "complete systems programming toolset";
        };
      };
    };
  };
  
  config = mkMerge [
    # Rust ecosystem
    (mkIf cfg.rust.enable {
      home.packages = with pkgs; [
        rustc
        cargo
        rustfmt
        clippy
      ] ++ optionals cfg.rust.enableDev [
        rust-analyzer
        # cargo-edit    # From original rustlang category  
        # rust-script
        # rustscan
        # rustcat
      ] ++ optionals cfg.rust.enableUtilities [
        ripgrep  # Already in base
        bat
        fd
        # Other Rust utilities from utilities category
        hyperfine
        bandwhich
        tealdeer
        tokei
        procs
        grex
        delta  # Already in base
      ];
    })
    
    # Go ecosystem  
    (mkIf cfg.go.enable {
      home.packages = with pkgs; [
        go
      ] ++ optionals cfg.go.enableDev [
        # goreleaser    # From original golang category
        # go-task
        # gofumpt
        # gobang
        gopls
        golangci-lint
        delve
      ];
    })
    
    # C++ development
    (mkIf cfg.cpp.enable {
      home.packages = with pkgs; [
        cppCompiler  # Platform-specific: clang on macOS, gcc on Linux
        cmake
        ninja
        gdb  # From utilities
        clang-tools
      ];
    })
    
    # Assembly development
    (mkIf cfg.assembly.enable {
      home.packages = with pkgs; [
        # asmfmt    # From original asm category
        nasm
        gdb
      ] ++ optionals pkgs.stdenv.isLinux [
        # zlib    # From original asm category
      ];
    })
    
    # Full systems programming stack
    (mkIf cfg.enableFullStack {
      blackmatter.components.shell.packages.ecosystems.systemsProgramming = {
        rust.enable = mkDefault true;
        rust.enableDev = mkDefault true;
        go.enable = mkDefault true;
        go.enableDev = mkDefault true;
        cpp.enable = mkDefault true;
      };
    })
  ];
}