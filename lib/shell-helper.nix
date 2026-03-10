# Shell Plugin Helper - Modular shell enhancement management
# Similar to plugin-helper.nix for neovim, but for shell plugins
{
  lib,
  pkgs,
  ...
}:
with lib; let
  # Common configuration home for shell plugins
  common = {
    configHome = ". ~/.config/shell/plugins";
  };

  # Shell engine — Rust binary with serde_json for proper JSON parsing.
  # Reads the shell manifest (JSON) and outputs zsh source commands.
  shellEngine = pkgs.rustPlatform.buildRustPackage {
    pname = "bm-shell-engine";
    version = "0.1.0";
    src = ./shell-engine;
    cargoLock.lockFile = ./shell-engine/Cargo.lock;
  };

  # Convert Nix value to shell-compatible format (for env vars, arrays, etc.)
  toShellValue = lib.fix (self: val:
    if builtins.isString val
    then ''"${val}"''
    else if builtins.isBool val
    then (if val then "true" else "false")
    else if builtins.isInt val
    then toString val
    else if builtins.isList val
    then let
      items = map self val;
      joined = concatStringsSep " " items;
    in "(${joined})"
    else if builtins.isAttrs val
    then let
      pairs = lib.mapAttrsToList (k: v: "${k}=${self v}") val;
      joined = concatStringsSep "\n" pairs;
    in joined
    else throw "Unsupported shell value type: ${builtins.typeOf val}");

  # Generate Nix module for a shell plugin
  # Takes a plugin declaration and generates options + config
  mkPlugin = pluginDecl: let
    author = pluginDecl.author;
    name = pluginDecl.name;
    configDir = pluginDecl.configDir or null;
    priority = pluginDecl.load.priority or 50;

    # Replace dots with dashes for Nix option names
    nameWithDashes = lib.replaceStrings ["."] ["-"] name;

    # Path where config will be symlinked
    configPath =
      if configDir != null
      then "${common.configHome}/${author}/${nameWithDashes}"
      else null;
  in {
    lib,
    pkgs,
    config,
    ...
  }:
    with lib; {
      options.blackmatter.components.shell.plugins.${author}.${nameWithDashes} = {
        enable = mkEnableOption "enable ${author}/${name}";
        priority = mkOption {
          type = types.int;
          default = priority;
          description = "Loading priority (lower = earlier)";
        };
        defer = mkOption {
          type = types.bool;
          default = pluginDecl.load.defer or false;
          description = "Defer loading until after first prompt";
        };
      };

      config = mkIf config.blackmatter.components.shell.plugins.${author}.${nameWithDashes}.enable (mkMerge [
        # Symlink config directory if it exists
        (mkIf (configDir != null) {
          xdg.configFile."shell/plugins/${author}/${nameWithDashes}" = {
            source = configDir;
            recursive = true;
          };
        })

        # Install package from nixpkgs if source type is nixpkgs
        (mkIf (pluginDecl.source.type or null == "nixpkgs") {
          home.packages = [
            (getAttrFromPath (lib.splitString "." pluginDecl.source.package) pkgs)
          ];
        })

        # Fetch from GitHub if source type is github
        (mkIf (pluginDecl.source.type or null == "github") {
          home.file.".local/share/shell/plugins/${author}/${name}" = {
            source = builtins.fetchGit {
              url = "https://github.com/${pluginDecl.source.repo}";
              ref = pluginDecl.source.ref or "main";
              rev = pluginDecl.source.rev;
            };
            recursive = true;
          };
        })
      ]);
    };

  # Generate source line for a single plugin (flat, no Nix indent nesting)
  mkSourceLine = decl: let
    author = decl.author;
    name = decl.name;
    nameWithDashes = lib.replaceStrings ["."] ["-"] name;
    initFile = decl.load.initFile or "init.zsh";
    path = "~/.config/shell/plugins/${author}/${nameWithDashes}/${initFile}";
  in "[[ -f ${path} ]] && source ${path}";

  # Generate shell initialization code for enabled plugins
  # Partitions into immediate and deferred (post-first-prompt) loading
  #
  # All output is built via explicit string concatenation — no Nix indented
  # string interpolation of multi-line values, which silently drops indent
  # on lines after the first and produces malformed zsh function bodies.
  mkPluginInits = pluginDecls: config: let
    # Filter to only enabled plugins
    enabledPlugins = lib.filter (decl:
      config.blackmatter.components.shell.plugins.${decl.author}.${lib.replaceStrings ["."] ["-"] decl.name}.enable or false
    ) pluginDecls;

    # Sort by priority (lower number = load earlier)
    sortedPlugins = lib.sort (a: b:
      (a.load.priority or 50) < (b.load.priority or 50)
    ) enabledPlugins;

    # Partition into immediate vs deferred
    immediatePlugins = lib.filter (decl: !(decl.load.defer or false)) sortedPlugins;
    deferredPlugins = lib.filter (decl: decl.load.defer or false) sortedPlugins;

    # Immediate plugins: one source line per plugin (top-level, no indent)
    immediateBlock = lib.concatMapStringsSep "\n" (decl:
      "# ${decl.author}/${decl.name}\n" + mkSourceLine decl
    ) immediatePlugins;

    # Deferred plugins: static function that sources after first prompt
    # Built line-by-line to avoid Nix indented string interpolation issues
    deferredBlock =
      if deferredPlugins == []
      then ""
      else let
        deferredLines = lib.concatMapStringsSep "\n" (decl:
          "  " + mkSourceLine decl
        ) deferredPlugins;
      in lib.concatStringsSep "\n" [
        ""
        "# ===== DEFERRED PLUGINS (loaded after first prompt) ====="
        "__blackmatter_deferred() {"
        "  add-zsh-hook -d precmd __blackmatter_deferred"
        "  unfunction __blackmatter_deferred"
        deferredLines
        "}"
        "autoload -Uz add-zsh-hook"
        "add-zsh-hook precmd __blackmatter_deferred"
      ];
  in
    immediateBlock + deferredBlock;

  # Generate .zshrc with plugin loading
  mkZshrc = pluginDecls: config: let
    pluginInits = mkPluginInits pluginDecls config;
  in ''
    # ~/.zshrc - Generated by Nix (blackmatter shell component)
    # DO NOT EDIT - Changes will be overwritten

    # Load core shell settings
    [[ -f ~/.config/shell/groups/common/settings.zsh ]] && \
      source ~/.config/shell/groups/common/settings.zsh

    # Initialize plugins (sorted by priority)
    ${pluginInits}

    # Load shell groups
    for group in ~/.config/shell/groups/*/init.zsh; do
      [[ -f "$group" ]] && source "$group"
    done
  '';
  # Generate a JSON shell engine manifest for the Rust binary.
  # Uses JSON as a proper machine-readable boundary between Nix and Rust.
  # The manifest describes all sources, deferred plugins, scan dirs, and
  # cleanup targets — the Rust engine reads this and outputs correct shell.
  mkShellManifest = {
    preSources ? [],      # source paths loaded before plugins
    pluginDecls ? [],      # plugin declarations (uses config to filter enabled)
    config,                # home-manager config (for checking enabled plugins)
    postSources ? [],      # source paths loaded after plugins
    scanDirs ? [],         # directories to scan for *.zsh at runtime
    cleanPaths ? [],       # stale cache files to delete
  }: let
    enabledPlugins = lib.filter (decl:
      config.blackmatter.components.shell.plugins.${decl.author}.${lib.replaceStrings ["."] ["-"] decl.name}.enable or false
    ) pluginDecls;

    sortedPlugins = lib.sort (a: b:
      (a.load.priority or 50) < (b.load.priority or 50)
    ) enabledPlugins;

    immediatePlugins = lib.filter (decl: !(decl.load.defer or false)) sortedPlugins;
    deferredPlugins = lib.filter (decl: decl.load.defer or false) sortedPlugins;

    mkPluginPath = decl: let
      nameWithDashes = lib.replaceStrings ["."] ["-"] decl.name;
      initFile = decl.load.initFile or "init.zsh";
    in "~/.config/shell/plugins/${decl.author}/${nameWithDashes}/${initFile}";

    manifest = {
      pre_sources = preSources;
      plugins_immediate = map mkPluginPath immediatePlugins;
      plugins_deferred = map mkPluginPath deferredPlugins;
      post_sources = postSources;
      scan_dirs = scanDirs;
      clean_paths = cleanPaths;
    };
  in builtins.toJSON manifest;

in {
  inherit
    toShellValue
    mkPlugin
    mkSourceLine
    mkPluginInits
    mkZshrc
    mkShellManifest
    shellEngine
    ;
}
