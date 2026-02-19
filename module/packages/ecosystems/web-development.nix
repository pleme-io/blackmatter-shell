{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.shell.packages.ecosystems.webDevelopment;
in {
  options = {
    blackmatter = {
      components = {
        shell.packages.ecosystems.webDevelopment = {
          enable = mkEnableOption "web development ecosystem";
          
          javascript = {
            enable = mkEnableOption "JavaScript/Node.js tools";
            enableTypeScript = mkEnableOption "TypeScript tools";
            enableFrameworks = mkEnableOption "JavaScript framework tools";
            runtime = mkOption {
              type = types.enum [ "nodejs_18" "nodejs_20" "nodejs_latest" ];
              default = "nodejs_20";
              description = "Node.js runtime version";
            };
          };
          
          css = {
            enable = mkEnableOption "CSS development tools";
          };
          
          php = {
            enable = mkEnableOption "PHP development tools";
          };
          
          # Quick overlay for full web development
          enableFullStack = mkEnableOption "complete web development toolset";
        };
      };
    };
  };
  
  config = mkMerge [
    # JavaScript/Node.js ecosystem
    (mkIf cfg.javascript.enable {
      home.packages = with pkgs; 
        let
          nodeJs = {
            nodejs_18 = nodejs_18;
            nodejs_20 = nodejs_20;
            nodejs_latest = nodejs_latest;
          }.${cfg.javascript.runtime};
        in
        [
          nodeJs
          nodePackages.npm
          nodePackages.yarn
          nodePackages.pnpm
        ] ++ optionals cfg.javascript.enableTypeScript [
          typescript
          typescript-language-server
          # nodePackages.typescript-language-server
        ] ++ optionals cfg.javascript.enableFrameworks [
          nodePackages.create-react-app
          nodePackages.vite
          nodePackages.vue-cli
        ];
    })
    
    # CSS tools
    (mkIf cfg.css.enable {
      home.packages = with pkgs; [
        sass
        tailwindcss
        nodePackages.prettier
        # nodePackages.stylelint
        # nodePackages.autoprefixer
      ];
    })
    
    # PHP development
    (mkIf cfg.php.enable {
      home.packages = with pkgs; [
        php  # From original php category
        phpPackages.composer
        phpPackages.psalm
        phpPackages.phpunit
      ];
    })
    
    # Full web development stack
    (mkIf cfg.enableFullStack {
      blackmatter.components.shell.packages.ecosystems.webDevelopment = {
        javascript.enable = mkDefault true;
        javascript.enableTypeScript = mkDefault true;
        css.enable = mkDefault true;
        php.enable = mkDefault true;
      };
    })
  ];
}