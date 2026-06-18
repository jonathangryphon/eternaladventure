# /etc/nixos/hosts/rosalina-local.nix
{ config, pkgs, lib, ... }:
{
  imports = [ ../disks/rosalina-local-disk.nix ];

  networking.hostName = "Rosalina";
  networking.hostId = "a89675af";
  myServer.dataRoot = "/var/lib/services";
  myServer.zfsPoolReady = true;

  services.oink.enable = false;

  networking.firewall.allowedTCPPorts = [ 62022 80 443 ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/disk/by-id";
}