{ config, pkgs, lib, sops-nix, ... }:
{
  imports = [ 
    ./hardware-configuration.nix
    ../../modules/restic.nix
    ../../modules/zfs/base.nix
    ../../modules/traefik.nix
    ../../modules/wifi.nix
    ../../modules/monitoring.nix
    ../../modules/users/syncoid.nix
    ../../modules/services/nextcloud.nix
    ../../modules/services/ente.nix
    ../../modules/services/traefik-dashboard.nix
    ../../modules/services/minecraft-server.nix
    ../../modules/services/headscale-server.nix  
  ];

  networking.hostName = "Afabel"; # cuz driven by eternity

  # OPTIONS
  myServer.dataRoot = "/tank/services"; # modules/server_arch.nix option for centralizing service data directory definitions
  mySsh.port = 62022;
  # ZFS 
  boot.zfs.extraPools = [ "tank" ];
  boot.zfs.forceImportRoot = false; # root drive is not zfs, only ext4
  networking.hostId = "c2dfeb62"; # unique host ID required by zfs
  ############################
  # Boot
  ############################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # ZFS
  boot.kernelModules = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];

  time.timeZone = "America/Chicago";

  # DDNS
  services.oink.enable = false;

  # "KEEP" PROXY
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.2/24" ];
    privateKeyFile = "/run/secrets/wg-afabel-key";
    peers = [{
      publicKey = "0iQVcRdUygTb1f8afgPXnrzj1CiDMUH3LP/JURY9LQY=";
      endpoint = (import /etc/nixos-local/wg-peers.nix).endpoint;
      allowedIPs = [ "10.100.0.1/32" ];
      persistentKeepalive = 25;
    }];
  };
  sops.secrets.wg-afabel-key = {
    sopsFile = ../../secrets/afabel.yaml;
    format = "yaml";
  };

  environment.systemPackages = with pkgs; [
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