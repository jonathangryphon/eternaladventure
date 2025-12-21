{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./ssh.nix
    ./zfs.nix
    ./traefik.nix
    ./podman-containers.nix
    ./services/ente.nix
#    ./services/headscale.nix
# supposedly headscale is really just vpn without exposing port 22, so in my use case,
# it doesn't seem to matter, although it's unclear as to why so much... i mean there are
# multiple things going on with that... so idk
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
  # DDNS with Oink for Porkbun
  ############################
  services.oink = {
    enable = true;
    apiKeyFile = "/etc/secrets/porkbun-api-key";
    secretApiKeyFile = "/etc/secrets/porkbun-secret-api-key";
    settings.interval = 900; # seconds between updates
    settings.ttl = 600;      # DNS TTL
    domains = [
      { domain = "eternaladventure.xyz"; subdomain = ""; ttl = 600; }
    ];
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
  ];

  ############################
  # First NixOS version installed
  ############################
  system.stateVersion = "";
};
