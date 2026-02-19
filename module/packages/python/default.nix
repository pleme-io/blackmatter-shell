pkgs: with pkgs; [
  # Python Language Server (for IDE/LSP support)
  pyright  # Microsoft's fast Python type checker and LSP

  # Python formatting and linting
  ruff       # Extremely fast Python linter (replaces flake8, isort, etc.)
  black      # Python code formatter

  # Python package management
  uv         # Fast Python package installer (replaces pip, poetry)
]
