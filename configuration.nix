{config, pkgs, lib,  ... }:


let
  ############################
  # BOOTSTRAP FLAGS
  ############################
  zfsPoolReady = false; # flip to true AFTER creating ZFS pool
  enableSops = false; # flip to true AFTER copying AGE key to /home/charity/.config/sops/age/keys.txt
  sopsNix = builtins.fetchTarball {
    url = "https://github.com/Mic92/sops-nix/archive/9836912e37aef546029e48c8749834735a6b9dad.tar.gz";
    sha256 = "1sk77hv4x1dg7b1c7vpi5npa7smgz726l0rzywlzw80hwk085qh4";
  };
in
{
  imports = [
    ./hardware-configuration.nix
    ./modules/podman.nix
    ./modules/ssh.nix
    ./modules/traefik.nix
    ./modules/oink_ddns.nix
#    ./modules/services/ente.nix
    ./modules/services/traefik-dashboard.nix
    ./users.nix
  ]  
    # ZFS-dependent config 
    ++ lib.optionals zfsPoolReady [
      ./modules/zfs.nix
    ]
    # Secrets + secret-dependent services configs
    ++ lib.optionals enableSops [
    ./sops-secrets.nix
    ./modules/oink.nix
    ./modules/wifi.nix

    # Obtain sops-nix via fetchTarball
    sopsNix/modules/sops
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
    age
  ];

  ############################
  # First NixOS version installed
  ############################
  system.stateVersion = "25.11";
}
