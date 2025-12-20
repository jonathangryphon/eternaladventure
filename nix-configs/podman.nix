{ config, pkgs, lib, ... }:

{
  # Podman service
  services.podman.enable = true;
  services.podman.socket = true; # system-wide socket for Traefik

  # Optional: only if you want rootless helpers, maybe a later todo for security
  # virtualization.podman.enable = true;

  # Docker compatibility not needed unless using docker direct YAML configs and such
  # services.podman.dockerCompat = false;

  # Podman-compose optional, not required for NixOS-managed containers
  # environment.systemPackages = [ pkgs.podman-compose ];
}

