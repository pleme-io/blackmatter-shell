{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.blackmatter.components.shell.packages.ecosystems.cloudInfrastructure;
in {
  options = {
    blackmatter = {
      components = {
        shell.packages.ecosystems.cloudInfrastructure = {
          enable = mkEnableOption "cloud infrastructure ecosystem";
          
          aws = {
            enable = mkEnableOption "AWS tools";
            enableAll = mkEnableOption "all AWS packages";
          };
          
          hashicorp = {
            enable = mkEnableOption "HashiCorp tools"; 
            enableAll = mkEnableOption "all HashiCorp packages";
          };
          
          kubernetes = {
            enable = mkEnableOption "Kubernetes tools";
            enableAll = mkEnableOption "all Kubernetes packages";
          };
          
          containers = {
            enable = mkEnableOption "Container tools";
            enableAll = mkEnableOption "all container packages";
          };
          
          # Quick overlay for full cloud development
          enableFullStack = mkEnableOption "complete cloud infrastructure toolset";
        };
      };
    };
  };
  
  config = mkMerge [
    # Individual AWS packages
    (mkIf cfg.aws.enable {
      home.packages = with pkgs; [
        # awscli2 # Disabled: slow test suite hangs builds
      ] ++ optionals cfg.aws.enableAll [
        ssm-session-manager-plugin
        # cloud-nuke  # Commented in original
        # nodePackages_latest.cdktf-cli  # Commented in original
      ];
    })
    
    # HashiCorp ecosystem
    (mkIf cfg.hashicorp.enable {
      home.packages = with pkgs; [
        terraform
      ] ++ optionals cfg.hashicorp.enableAll [
        # terraform-ls  # From original hashicorp category
        # tflint
        # terraform-docs
        # terraform-landscape
        # terraform-compliance
      ];
    })
    
    # Kubernetes ecosystem
    (mkIf cfg.kubernetes.enable {
      home.packages = with pkgs; [
        kubectl
      ] ++ optionals cfg.kubernetes.enableAll [
        helm
        kind
        k9s
        kubectx
      ];
    })
    
    # Container tools
    (mkIf cfg.containers.enable {
      home.packages = with pkgs; [
        arion  # Already in base packages
      ] ++ optionals cfg.containers.enableAll [
        docker-compose
        podman
        buildah
      ];
    })
    
    # Full stack overlay - enables commonly used tools together
    (mkIf cfg.enableFullStack {
      blackmatter.components.shell.packages.ecosystems.cloudInfrastructure = {
        aws.enable = mkDefault true;
        hashicorp.enable = mkDefault true;
        kubernetes.enable = mkDefault true;
        containers.enable = mkDefault true;
      };
    })
  ];
}