pkgs: with pkgs; [
  # TypeScript/JavaScript Language Server (for IDE/LSP support)
  nodePackages.typescript-language-server  # TypeScript/JavaScript LSP
  nodePackages.typescript                   # TypeScript compiler (required by LSP)

  # Additional language servers
  nodePackages.vscode-langservers-extracted  # HTML, CSS, JSON, ESLint LSPs

  # JavaScript/TypeScript tooling
  nodejs_22    # Node.js runtime (LTS)
  bun          # Fast JavaScript runtime and package manager

  # Formatting and linting
  nodePackages.prettier  # Code formatter
  biome                  # Fast linter and formatter (Rust-based)
]
