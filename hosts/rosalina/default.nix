{ config, pkgs, lib, sops-nix, ... }:
{
  imports = [
    # disko takes care of this: ./hardware-rosalina.nix
    (import disko.nix { device = "/dev/sda"; }) 
    ../../modules/restic.nix
    ../../modules/zfs.nix
    ../../modules/traefik.nix
    ../../modules/services/nextcloud.nix
    ../../modules/services/ente.nix
    ../../modules/services/traefik-dashboard.nix
    ../../modules/services/minecraft-server.nix
    ../../modules/users/syncoid.nix
  ];

  networking.hostName = "Rosalina"; # cuz the vps lives in a galaxy
  time.timeZone = "America/Chicago"; # FIXME according to vps location

  # BOOT
  boot.kernelParams = [ "zfs.zfs_arc_max=536870912" ]; # cap ARC at 512MB
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub.enable = lib.mkForce true;
  boot.loader.grub.efiSupport = lib.mkForce false;
  systemd.network.wait-online.anyInterface = true; # prevents weird networkd error about being online, well, it should have.... but networkd is weird with pre-configured networks so we also add the below line (which makes this unnecessary bloat)
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false; # disables that networkd check service entirely to prevent weird buggy issue
  boot.kernelModules = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];

  # ZFS 
  boot.zfs.forceImportRoot = true;
  boot.zfs.extraPools = [ "tank" ];
  networking.hostId = "a7b7c7d7";
  myServer.dataRoot = "/var/lib/services";

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
      "37.27.178.222/32" # VPS IPv4 addr
      "2a01:4f9:c010:b39f::1/64" # VPS IPv6 addr
    ];
    routes = [ # VPS gateway info
      { routeConfig.Destination = "172.31.1.1"; } 
      { routeConfig.Gateway = "172.31.1.1"; routeConfig.GatewayOnLink = true; }
      { routeConfig.Gateway = "fe80::1"; }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  system.stateVersion = "25.11";

}