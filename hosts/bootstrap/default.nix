{ config, pkgs, lib, disko, sops-nix, ... }:
{
  imports = [
    # disko takes care of this: ./hardware-rosalina.nix
    # (import disko.nix { device = "/dev/sda"; }) 
    ../../modules/zfs/base.nix
    ./hardware-bootstrap.nix
  ];

  networking.hostName = "bootstrap"; 
  time.timeZone = "Europe/Helsinki";

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
  boot.zfs.extraPools = [ "tank" ];
  networking.hostId = "a8b8c8d8";
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
  #fileSystems."/boot" = {
   # device = "/dev/disk/by-uuid/D45D-0AB7";
    #fsType = "vfat";
  #};

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

  #networking.wireguard.interfaces.wg0 = {
   # ips = [ "10.100.0.8/24" ];
    #privateKeyFile = "/run/secrets/wg-rosalina-key";
    #peers = [{
    #  publicKey = "0iQVcRdUygTb1f8afgPXnrzj1CiDMUH3LP/JURY9LQY=";
    #  endpoint = if builtins.pathExists /etc/nixos-local/wg-peers.nix
    #    then (import /etc/nixos-local/wg-peers.nix).endpoint
    #    else "keep.eternaladventure.xyz"; # fallback literal, override locally later
    #  allowedIPs = [ "10.100.0.1/32" ];
    #  persistentKeepalive = 25;
   # }];
  #};

  #sops.secrets.wg-rosalina-key = {
  #  sopsFile = ../../secrets/rosalina.yaml;
  #  format = "yaml";
  #};

  # TEMP USER
  users.users.bootstrap = {
    isNormalUser = true;
    description = "temporary bootstrap recovery user";
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$3a9LukEfdq.2jzGY$b/HQaYoycYxW/4DbvliJ.jw4BdBBqGv6d8Ch9dhSNu1rHFwmnzORVTkgSOXAANNt4m5YY/f2.47OggeAGTwqD0";
 };

  services.openssh.settings = {
    PasswordAuthentication = lib.mkForce true;
    KbdInteractiveAuthentication = lib.mkForce false;
    AllowUsers = [ "charity" "breakglass" "bootstrap" ];
  };


  # OPTIONS
  mySsh.port = 62028;

  system.stateVersion = "25.11";
}