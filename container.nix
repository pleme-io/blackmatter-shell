# container.nix - Blackmatter Shell as a Docker/OCI container image
#
# Intended for use as a Kubernetes debug pod or container-based dev environment.
# Root user, all blzsh tools available, accessible as a k8s ephemeral container.
#
# Usage:
#   # Run locally
#   nix build .#packages.x86_64-linux.container
#   docker load < result
#   docker run --rm -it ghcr.io/pleme-io/blackmatter-shell:latest
#
#   # K8s debug pod
#   kubectl run debug --image=ghcr.io/pleme-io/blackmatter-shell:latest --rm -it --restart=Never
#
#   # Attach to running pod as ephemeral container
#   kubectl debug -it <pod> --image=ghcr.io/pleme-io/blackmatter-shell:latest --target=<container>
{
  pkgs,
  lib,
  blackmatter-nvim,
}:
let
  blzsh = import ./package.nix { inherit pkgs lib blackmatter-nvim; };

  # Baseline Unix tools needed for scripts, tools, and general container usability.
  # The blzsh closure already includes all Rust power tools (bat, eza, fd, rg, delta, etc.).
  # These are standard POSIX utilities that scripts and kubernetes tooling depend on.
  baselineTools = with pkgs; [
    bashInteractive # /bin/bash for fallback and scripting
    coreutils # ls, cat, cp, mv, rm, chmod, chown, etc.
    findutils # find, xargs (POSIX-compatible, not fd — scripts rely on these)
    gnugrep # grep (POSIX-compatible, not rg — flag syntax differs)
    gnutar # tar
    gzip # gzip/gunzip
    git # version control — essential in debug scenarios
    curl # HTTP — xh is in blzsh but curl has wider script compat
    openssh # ssh client for remote debugging
    cacert # SSL certificates for HTTPS
    pkgs.dockerTools.fakeNss # /etc/passwd, /etc/group for root
  ];
in
pkgs.dockerTools.buildLayeredImage {
  name = "ghcr.io/pleme-io/blackmatter-shell";
  tag = "latest";

  # The blzsh closure includes all 35 Rust tools + zsh + starship + blnvim.
  # baselineTools adds standard Unix utilities for broad compatibility.
  contents = [ blzsh ] ++ baselineTools;

  extraCommands = ''
    # Standard directories every container needs
    mkdir -p root tmp
    chmod 1777 tmp

    # Symlink shells to /bin for tooling that hardcodes /bin/bash or /bin/sh
    mkdir -p bin
    ln -s ${pkgs.bashInteractive}/bin/bash bin/bash
    ln -s ${pkgs.bashInteractive}/bin/bash bin/sh
    ln -s ${blzsh}/bin/blzsh bin/blzsh

    # Symlink common tools to /usr/bin for broader PATH compatibility
    mkdir -p usr/bin
    ln -s ${pkgs.coreutils}/bin/env usr/bin/env
  '';

  config = {
    # blzsh sets ZDOTDIR, DIRENV_CONFIG, and prepends all tools to PATH on launch.
    # Users get the full blackmatter shell experience immediately.
    Cmd = [ "/bin/blzsh" ];
    WorkingDir = "/root";
    Env = [
      "HOME=/root"
      "USER=root"
      "TERM=xterm-256color"
      "COLORTERM=truecolor"
      "LANG=C.UTF-8"
      # SSL certs for curl, git, xh, and anything using HTTPS
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      "GIT_SSL_CAINFO=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      "CURL_CA_BUNDLE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/pleme-io/blackmatter-shell";
      "org.opencontainers.image.description" = "Blackmatter Shell — curated zsh debug environment with 35 bundled tools";
      "org.opencontainers.image.licenses" = "MIT";
    };
  };
}
