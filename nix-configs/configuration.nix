{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/zfs.nix
    ./modules/podman.nix
    ./modules/ssh.nix
    ./modules/traefik.nix
    ./modules/oink_ddns.nix
    ./modules/services/ente.nix
    ./modules/services/traefik-dashboard.nix
#   ./modules/services/headscale.nix   
    ./users.nix
    ./secrets/porkbun_secrets.yaml
    ./nix/sources.json
    ./nix/sources.nix
    ./config/sops.yaml
#   ./sops-secrets.nix
  
    # sops-nix import via niv
    "${(import ./nix/sources.nix).sops-nix}/modules/sops"
  ];

  ############################
  # Boot
  ############################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ############################
  # Networking & Firewall
  ############################
#  networking.networkmanager.enable = true;
# chatgpt didn't like for a server, said unnecessary, instead do below
  networking.useDHCP = true;
  networking.firewall.allowedTCPPorts = [ 80 443 62022 ]; # 62022 is personal ssh port

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
  security.sudo.wheelNeedsPassword = false; # users do not have pws, only ssh keys for auth

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
    neofetch
    sops
  ];

  ############################
  # First NixOS version installed
  ############################
  system.stateVersion = "";
};
