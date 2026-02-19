{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.shell.packages.ecosystems.devopsAutomation;
in {
  options = {
    blackmatter = {
      components = {
        shell.packages.ecosystems.devopsAutomation = {
          enable = mkEnableOption "DevOps automation ecosystem";
          
          configManagement = {
            enable = mkEnableOption "Configuration management tools";
          };
          
          cicd = {
            enable = mkEnableOption "CI/CD tools";
          };
          
          monitoring = {
            enable = mkEnableOption "Monitoring and observability tools";
          };
          
          gitTools = {
            enable = mkEnableOption "Advanced Git tools";
          };
          
          secrets = {
            enable = mkEnableOption "Secret management tools";
          };
          
          # Quick overlay for full DevOps workflow
          enableFullStack = mkEnableOption "complete DevOps automation toolset";
        };
      };
    };
  };
  
  config = mkMerge [
    # Configuration management
    (mkIf cfg.configManagement.enable {
      home.packages = with pkgs; [
        ansible  # From utilities category
        # chef
        # puppet
      ];
    })
    
    # CI/CD tools
    (mkIf cfg.cicd.enable {
      home.packages = with pkgs; [
        gh  # GitHub CLI - already in base
        # jenkins-cli
        # gitlab-runner
      ];
    })
    
    # Monitoring and observability
    (mkIf cfg.monitoring.enable {
      home.packages = with pkgs; [
        # prometheus
        # grafana
        # influxdb-cli
        # vector
        htop
        iotop
        nethogs
        bandwhich  # From utilities - network monitoring
      ];
    })
    
    # Advanced Git tools  
    (mkIf cfg.gitTools.enable {
      home.packages = with pkgs; [
        lazygit  # Already in base
        tig      # From utilities
        delta    # Already in base
        # git-absorb
        # git-branchless
        # onefetch
        # gitmux
      ];
    })
    
    # Secret management
    (mkIf cfg.secrets.enable {
      home.packages = with pkgs; [
        sops  # Already in base and secrets category
        age   # From secrets category
        # vault
        # bitwarden-cli
        # pass
      ];
    })
    
    # Full DevOps automation stack
    (mkIf cfg.enableFullStack {
      blackmatter.components.shell.packages.ecosystems.devopsAutomation = {
        configManagement.enable = mkDefault true;
        cicd.enable = mkDefault true;
        monitoring.enable = mkDefault true;
        gitTools.enable = mkDefault true;
        secrets.enable = mkDefault true;
      };
    })
  ];
}