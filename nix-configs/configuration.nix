{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./ssh.nix
    ./zfs.nix
    ./podman-containers.nix
    ./services/ente.nix
    ./services/traefik.nix
    ./services/headscale.nix
  ];

  ############################
  # Boot
  ############################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ############################
  # Networking & Firewall
  ############################
  networking.networkmanager.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  ############################
  # Host & Timezone
  ############################
  networking.hostName = "Afabel";
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
	
  ############################
  # Security
  ############################
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;

  ############################
  # Auto Update
  ############################
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";         # or "weekly"
    persistent = true;       # keeps schedule after reboots
    allowReboot = true;      # reboot automatically if needed (optional)
    rebootWindow = {         # optional safe reboot window
      lower = "02:00";
      upper = "03:00";
    };
  };

  ############################
  # System Packages
  ############################
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    zfs
  ];

  ############################
  # First NixOS version installed
  ############################
  system.stateVersion = "";
};
