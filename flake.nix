{
  description = "Blackmatter Shell - curated zsh distribution with 7 plugins and 35 bundled tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    blackmatter-nvim = {
      url = "github:pleme-io/blackmatter-nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    skim-tab = {
      url = "github:pleme-io/skim-tab";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blx = {
      url = "github:pleme-io/blx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bm-guard = {
      url = "github:pleme-io/bm-guard";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    blackmatter-nvim,
    skim-tab,
    blx,
    bm-guard,
    devenv,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});
  in {
    packages = forAllSystems (pkgs: {
      default = import ./package.nix {
        inherit pkgs blackmatter-nvim skim-tab blx bm-guard;
        lib = nixpkgs.lib;
      };
      blzsh = import ./package.nix {
        inherit pkgs blackmatter-nvim skim-tab blx bm-guard;
        lib = nixpkgs.lib;
      };
    });

    homeManagerModules.default = import ./module;

    overlays.default = final: prev: {
      blzsh = self.packages.${final.system}.blzsh;
      skim-tab = skim-tab.packages.${final.system}.default;
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
      devenv = devenv.lib.mkShell {
        inputs = { inherit nixpkgs devenv; };
        inherit pkgs;
        modules = [{
          languages.nix.enable = true;
          packages = with pkgs; [ nixpkgs-fmt nil ];
          git-hooks.hooks.nixpkgs-fmt.enable = true;
        }];
      };
    });
  };
}
