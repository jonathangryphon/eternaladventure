{ config, pkgs, lib, ... }:
{
  imports = [
    # disko takes care of this: ./hardware-rosalina.nix
    (import ../disks/rosalina-disk.nix { device = "/dev/sda"; }) 
  ];
  networking.hostName = "Rosalina";
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
  };

  fileSystems."/nix" = {
    device = "tank/local/nix";
    fsType = "zfs";
  };
  # Boot details so that ZFS encrypted datasets can be implemented and ensure security from VPS provider
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh = {
    enable = true;
    port = 62021;
    authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHawf4YO7tfG/BkWfw0E+aQRThKTIsGjXSwDBfQK/VGF charity@macbook" ];
    hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
  };
  boot.initrd.availableKernelModules = [ "zfs" ];
  boot.initrd.systemd.enable = true;  # required for initrd SSH on recent NixOS

  # Traefik ACME — use a separate cert resolver or staging for VPS
  # to avoid hitting Let's Encrypt rate limits on your real domain
}