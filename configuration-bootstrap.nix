{ lib, pkgs, sops-nix, ... }:

{
  ############################
  # Boot
  ############################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];

  ############################
  # Networking & Firewall
  ############################
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  ############################
  # Host & Timezone
  ############################
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  ############################
  # Security
  ############################
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  ############################
  # Flake support
  ############################
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  ############################
  # System Packages
  ############################
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    htop
    sops
    age
  ];

  ############################
  # First NixOS version installed
  ############################
  system.stateVersion = "25.11";

  ############################
  # Imports
  ############################
  imports = [
    ./modules/server_arch.nix
    ./modules/podman.nix
    ./modules/ssh.nix
    ./modules/traefik.nix
    "${sops-nix}/modules/sops"
    ./sops-secrets.nix
    ./modules/sops.nix
    ./users.nix
    ./modules/zfs.nix
  ];
}