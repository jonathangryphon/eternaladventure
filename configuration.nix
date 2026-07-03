{config, pkgs, lib,  sops-nix, ... }:

{
  imports = [
    ./modules/server_arch.nix
    ./modules/podman.nix
    ./modules/ssh.nix
    ./modules/traefik.nix
    "${sops-nix}/modules/sops"
    ./sops-secrets.nix
    ./modules/sops.nix
    ./modules/services/nextcloud.nix
    ./modules/services/ente.nix
    ./modules/services/traefik-dashboard.nix
    ./modules/services/minecraft-server.nix
    ./users.nix
  ]  
    # ZFS-dependent config 
    ++ lib.optionals zfsPoolReady [
      ./modules/zfs.nix
    ]
    # Secrets + secret-dependent services configs
    ++ lib.optionals enableSops [
   # ./modules/sops.nix
   # ./sops-secrets.nix
    ./modules/oink_ddns.nix
    ./modules/wifi.nix
    ];

  ############################
  # Boot
  ############################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # ZFS
  boot.kernelModules = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];

  ############################
  # Networking & Firewall    # see modules/wifi.nix for more
  ############################
  networking.firewall.allowedTCPPorts = [ 80 443 ]; # other ports defined in their own modules

  ############################
  # Host & Timezone
  ############################
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
	
  ############################
  # Security
  ############################
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false; # users do not have pws, only ssh keys for auth
  nix.settings.trusted-users = [ "charity" ];

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
  # Flake support
  ############################
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  ############################
  # System Packages
  ############################
  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    # Core CLI
    vim git wget btop neofetch

    # Secrets
    sops age

    # ZFS backup (sanoid/syncoid pipeline)
    sanoid pv mbuffer lzop zstd

    # Media/file tools (Nextcloud/Ente related?)
    ffmpeg exiftool
  ];

  ############################
  # First NixOS version installed
  ############################
  system.stateVersion = "25.11";
}
