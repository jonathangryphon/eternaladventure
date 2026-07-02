{ config, pkgs, lib, ... }:
{
  imports = [
    # disko takes care of this: ./hardware-rosalina.nix
    (import ../disks/rosalina-disk.nix { device = "/dev/sda"; }) 
  ];
  networking.hostName = "Rosalina";

  # Kernel module imports
  # boot.initrd.availableKernelModules = [ "ahci" "virtio_pci" "virtio_scsi" "virtio_blk" "sd_mod" "sr_mod" ];
  boot.kernelParams = [ "zfs.zfs_arc_max=536870912" ]; # cap ARC at 512MB
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub.enable = lib.mkForce true;
  boot.loader.grub.efiSupport = lib.mkForce false;
  systemd.network.wait-online.anyInterface = true; # prevents weird networkd error about being online
  # ZFS imports
  boot.zfs.forceImportRoot = true;
  boot.zfs.extraPools = [ "tank" ];

  # ZFS requires a Host ID 
  networking.hostId = "a7b7c7d7";
  myServer.dataRoot = "/var/lib/services";

  # Static subdomain — no dynamic DNS needed (VPS IPs don't change)
  services.oink.enable = false;

  # No ZFS pool on VPS
  myServer.zfsPoolReady = true;

  # Open ports for remote access
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Filesystem definitions for NixOS mounting process
  fileSystems."/" = {
    device = "tank/local/root";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/nix" = {
    device = "tank/local/nix";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  # --- new networking block ---
  networking.useNetworkd = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "eth0";
    networkConfig.DHCP = "no";
    address = [
      "37.27.178.222/32"
      "2a01:4f9:c010:b39f::1/64"
    ];
    routes = [
      { routeConfig.Destination = "172.31.1.1"; }
      { routeConfig.Gateway = "172.31.1.1"; routeConfig.GatewayOnLink = true; }
      { routeConfig.Gateway = "fe80::1"; }
    ];
    linkConfig.RequiredForOnline = "routable";
  };
  # --- end new block ---

  # Boot details so that ZFS encrypted datasets can be implemented and ensure security from VPS provider
  #boot.initrd.network.enable = true;
  #boot.initrd.network.ssh = {
  #  enable = true;
  #  port = 62021;
  #  authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHawf4YO7tfG/BkWfw0E+aQRThKTIsGjXSwDBfQK/VGF charity@macbook" ];
  #  hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
  #};
  #boot.initrd.availableKernelModules = [ "zfs" ];
  #boot.initrd.systemd.enable = true;  # required for initrd SSH on recent NixOS

  # Traefik ACME — use a separate cert resolver or staging for VPS
  # to avoid hitting Let's Encrypt rate limits on your real domain
}