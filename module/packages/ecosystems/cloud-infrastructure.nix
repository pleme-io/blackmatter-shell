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
            enable = mkEnableOption "AWS tools (CLI, SSM plugin)";
            enableAll = mkEnableOption "all AWS packages (cloud-nuke, cdktf)";
          };

          gcp = {
            enable = mkEnableOption "Google Cloud tools (gcloud SDK)";
            enableAll = mkEnableOption "all GCP packages";
          };

          azure = {
            enable = mkEnableOption "Azure tools (az CLI)";
            enableAll = mkEnableOption "all Azure packages";
          };

          hashicorp = {
            enable = mkEnableOption "HashiCorp tools (terraform)";
            enableAll = mkEnableOption "all HashiCorp packages";
          };

          kubernetes = {
            enable = mkEnableOption "Kubernetes tools (kubectl)";
            enableAll = mkEnableOption "all Kubernetes packages";
          };

          containers = {
            enable = mkEnableOption "Container tools";
            enableAll = mkEnableOption "all container packages";
          };

          # Quick toggle for full cloud development
          enableFullStack = mkEnableOption "complete cloud infrastructure toolset";
        };
      };
    };
  };

  config = mkMerge [
    # AWS
    (mkIf cfg.aws.enable {
      home.packages = with pkgs; [
        awscli2
      ] ++ optionals cfg.aws.enableAll [
        ssm-session-manager-plugin
      ];
    })

    # Google Cloud
    (mkIf cfg.gcp.enable {
      home.packages = with pkgs; [
        google-cloud-sdk
      ];
    })

    # Azure
    (mkIf cfg.azure.enable {
      home.packages = with pkgs; [
        azure-cli
      ];
    })

    # HashiCorp
    (mkIf cfg.hashicorp.enable {
      home.packages = with pkgs; [
        terraform
      ] ++ optionals cfg.hashicorp.enableAll [
        terraform-ls
        tflint
      ];
    })

    # Kubernetes
    (mkIf cfg.kubernetes.enable {
      home.packages = with pkgs; [
        kubectl
      ] ++ optionals cfg.kubernetes.enableAll [
        kubernetes-helm
        kind
        k9s
        kubectx
      ];
    })

    # Containers
    (mkIf cfg.containers.enable {
      home.packages = with pkgs; [
        arion
      ] ++ optionals cfg.containers.enableAll [
        docker-compose
        podman
        buildah
      ];
    })

    # Full stack — enables all providers + commonly used tools
    (mkIf cfg.enableFullStack {
      blackmatter.components.shell.packages.ecosystems.cloudInfrastructure = {
        aws.enable = mkDefault true;
        gcp.enable = mkDefault true;
        azure.enable = mkDefault true;
        hashicorp.enable = mkDefault true;
        kubernetes.enable = mkDefault true;
        containers.enable = mkDefault true;
      };
    })
  ];
}
