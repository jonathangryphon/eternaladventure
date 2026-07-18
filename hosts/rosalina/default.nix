{ config, pkgs, lib, disko, sops-nix, ... }:
{
  imports = [
    ./hardware-rosalina.nix
    ../../modules/restic.nix
    ../../modules/zfs/base.nix
    ../../modules/traefik.nix
    ../../modules/monitoring.nix
    ../../modules/users/syncoid.nix
    ../../modules/services.nix
  ];

  networking.hostName = "Rosalina"; # cuz the vps lives in a galaxy
  time.timeZone = "America/Chicago"; # FIXME according to vps location

  # BOOT
  boot.kernelParams = [ "zfs.zfs_arc_max=536870912" ]; # cap ARC at 512MB
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub.enable = lib.mkForce true;
  boot.loader.grub.zfsSupport = true;
  systemd.network.wait-online.anyInterface = true; # prevents weird networkd error about being online, well, it should have.... but networkd is weird with pre-configured networks so we also add the below line (which makes this unnecessary bloat)
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false; # disables that networkd check service entirely to prevent weird buggy issue
  boot.kernelModules = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.loader.grub.copyKernels = true;
  # ZFS 
  boot.zfs.forceImportRoot = true;
  boot.zfs.extraPools = [ "tank" "data" ];
  networking.hostId = "a8b8c8d8";

  # DDNS
  # TODO: remove module from hosts with static IPs entirely
  services.oink.enable = false; # turns off ddns

  # FILESYSTEMS
  # Filesystem definitions for NixOS mounting process
  fileSystems."/" = { # equivalent of fstab!
    device = "tank/local/root";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/nix" = {
    device = "tank/local/nix";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  # NETWORKING
  networking.useNetworkd = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "eth0";
    networkConfig.DHCP = "no";
    address = [
      "37.27.222.245/32" # VPS IPv4 addr
      "2a01:4f9:c015:91a3::1/64" # VPS IPv6 addr
    ];
    routes = [ # VPS gateway info
      { routeConfig.Destination = "172.31.1.1"; } 
      { routeConfig.Gateway = "172.31.1.1"; routeConfig.GatewayOnLink = true; }
      { routeConfig.Gateway = "fe80::1"; }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.7/24" ];
    privateKeyFile = "/run/secrets/wg-rosalina-key";
    peers = [{
      publicKey = "0iQVcRdUygTb1f8afgPXnrzj1CiDMUH3LP/JURY9LQY=";
      endpoint = if builtins.pathExists /etc/nixos-local/wg-peers.nix
        then (import /etc/nixos-local/wg-peers.nix).endpoint
        else "keep.eternaladventure.xyz"; # fallback literal, override locally later
      allowedIPs = [ "10.100.0.1/32" ];
      persistentKeepalive = 25;
    }];
  };

  sops.secrets.wg-rosalina-key = {
    sopsFile = ../../secrets/rosalina.yaml;
    format = "yaml";
  };


  sops.secrets.zfs-data-key = {
    sopsFile = ../../secrets/zfs-data-key.yaml;
    format = "yaml";
  };

  systemd.services.zfs-load-key-data = {
    description = "Load ZFS encryption key for data/services";
    after = [ "zfs-import-data.service" "sops-install-secrets.service" ];
    wants = [ "zfs-import-data.service" "sops-install-secrets.service" ];
    before = [ "zfs-mount.service" ];
    wantedBy = [ "zfs-mount.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "zfs-load-key-data" ''
        set -e
        if [ "$(${pkgs.zfs}/bin/zfs get -H -o value keystatus data/services)" != "available" ]; then
          ${pkgs.zfs}/bin/zfs load-key data/services
        fi
      '';
    };
  };

  # OPTIONS
  mySsh.port = 62025;
  myServer.dataRoot = "/var/lib/services";
  myServer.restic.repoPath = "b2:eternaladventure:/rosalina";
  
  system.stateVersion = "25.11";
}