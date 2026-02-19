pkgs: with pkgs; [
  # Nix Language Server (for IDE/LSP support)
  nixd  # Feature-rich Nix LSP (preferred over nil)

  # Nix formatting and linting
  nixfmt-rfc-style  # Official Nix formatter (RFC 166)
  statix            # Linter for Nix
  deadnix           # Find dead code in Nix
]
