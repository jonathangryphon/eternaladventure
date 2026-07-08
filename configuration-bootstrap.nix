{ lib, pkgs, sops-nix, ... }:

{
  ############################
  # Boot
  ############################
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = false;
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
  # Stub users for sops secret ownership
  # (real definitions live in ente.nix / garage's module, not imported here)
  ############################
  users.users.ente = {
    isSystemUser = true;
    group = "ente";
  };
  users.groups.ente = {};

  users.users.garage = {
    isSystemUser = true;
    group = "garage";
  };
  users.groups.garage = {};

  ############################
  # First NixOS version installed
  ############################
  system.stateVersion = "25.11";

  ############################
  # Imports
  ############################
  imports = [
    ./modules/server_arch.nix
    ./modules/ssh.nix
    ./modules/traefik.nix
    ./modules/users/core.nix
    ./modules/zfs.nix
  ];
}