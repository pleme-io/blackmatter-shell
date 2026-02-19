{
  description = "Blackmatter Shell - curated zsh distribution with 7 plugins and 35 bundled tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/d6c71932130818840fc8fe9509cf50be8c64634f";
    blackmatter-nvim = {
      url = "github:pleme-io/blackmatter-nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    blackmatter-nvim,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});
  in {
    packages = forAllSystems (pkgs: {
      default = import ./package.nix {
        inherit pkgs blackmatter-nvim;
        lib = nixpkgs.lib;
      };
      blzsh = import ./package.nix {
        inherit pkgs blackmatter-nvim;
        lib = nixpkgs.lib;
      };
    });

    homeManagerModules.default = import ./module;

    overlays.default = final: prev: {
      blzsh = self.packages.${final.system}.blzsh;
    };

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = [
          self.packages.${pkgs.system}.blzsh
          pkgs.nixd
          pkgs.shellcheck
          pkgs.shfmt
          pkgs.jq
        ];
        shellHook = ''
          echo "blackmatter-shell dev shell"
          echo "  blzsh      — run the standalone shell"
          echo "  nixd       — Nix LSP"
          echo "  shellcheck — shell script linter"
          echo "  shfmt      — shell script formatter"
        '';
      };
    });
  };
}
