{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.shell.packages.ecosystems;
in {
  imports = [
    ./cloud-infrastructure.nix
    ./devops-automation.nix
    ./systems-programming.nix
    ./web-development.nix
  ];
  
  options = {
    blackmatter = {
      components = {
        shell.packages.ecosystems = {
          enable = mkEnableOption "ecosystem-based package management";
          
          # Global overlay sets for common development workflows
          fullStackDeveloper = mkEnableOption "complete full-stack developer toolset";
          platformEngineer = mkEnableOption "complete platform engineering toolset";
          systemsDeveloper = mkEnableOption "complete systems development toolset";
          
          # Version management options
          versionManagement = {
            enable = mkEnableOption "advanced version management";
            
            nodejs = {
              versions = mkOption {
                type = types.listOf (types.enum [ "18" "20" "latest" ]);
                default = [ "20" ];
                description = "Node.js versions to install";
              };
            };
            
            python = {
              versions = mkOption {
                type = types.listOf (types.enum [ "39" "310" "311" "312" "313" ]);
                default = [ "312" ];
                description = "Python versions to install";
              };
            };
          };
        };
      };
    };
  };
  
  config = mkMerge [
    # Global workflow overlays
    (mkIf cfg.fullStackDeveloper {
      blackmatter.components.shell.packages.ecosystems = {
        webDevelopment.enableFullStack = mkDefault true;
        cloudInfrastructure.enableFullStack = mkDefault true;
        devopsAutomation.enableFullStack = mkDefault true;
      };
    })
    
    (mkIf cfg.platformEngineer {
      blackmatter.components.shell.packages.ecosystems = {
        cloudInfrastructure.enableFullStack = mkDefault true;
        devopsAutomation.enableFullStack = mkDefault true;
        systemsProgramming.go.enable = mkDefault true;
      };
    })
    
    (mkIf cfg.systemsDeveloper {
      blackmatter.components.shell.packages.ecosystems = {
        systemsProgramming.enableFullStack = mkDefault true;
        devopsAutomation.gitTools.enable = mkDefault true;
      };
    })
    
    # Version management implementation
    (mkIf cfg.versionManagement.enable {
      home.packages = with pkgs; 
        # Multiple Node.js versions
        (map (v: {
          "18" = nodejs_18;
          "20" = nodejs_20; 
          "latest" = nodejs_latest;
        }.${v}) cfg.versionManagement.nodejs.versions) ++
        
        # Multiple Python versions  
        (map (v: {
          "39" = python39;
          "310" = python310;
          "311" = python311;
          "312" = python312;
          "313" = python313;
        }.${v}) cfg.versionManagement.python.versions);
    })
  ];
}