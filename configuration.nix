{ config, pkgs, lib,  ... }:


let
  ############################
  # BOOTSTRAP FLAGS
  ############################
  zfsPoolReady = false; # flip to true AFTER creating ZFS pool
  enableSops = false; # flip to true AFTER copying AGE key to /home/charity/.config/sops/age/keys.txt
in
{
  imports =  with lib; [
    ./hardware-configuration.nix
    ./modules/podman.nix
    ./modules/ssh.nix
    ./modules/traefik.nix
    ./modules/oink_ddns.nix
    ./modules/services/ente.nix
    ./modules/services/traefik-dashboard.nix
    ./users.nix
    ./nix/sources.nix
  ]  
    # ZFS-dependent config 
    ++ (optionals zfsPoolReady [
      ./modules/zfs.nix
    ])
    # Secrets + secret-dependent services configs
    ++ (optionals enableSops [
    ./sops-secrets.nix
    ./modules/oink.nix
    ./modules/wifi.nix
 
    # sops-nix import via niv
    "${(import ./nix/sources.nix).sops-nix}/modules/sops"
    ]);

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
  networking.firewall.allowedTCPPorts = [ 80 443 ]; # ssh port is defined in /modules/ssh.nix

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
    neofetch
    sops
  ];

  ############################
  # First NixOS version installed
  ############################
  system.stateVersion = "25.11";
}
