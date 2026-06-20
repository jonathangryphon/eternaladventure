{ config, pkgs, lib, ... }:
{
  imports = [ ../hardware-configuration.nix ];

  networking.hostName = "Afabel";
  myServer.dataRoot = "/tank/services";
  myServer.zfsPoolReady = true;

  # ZFS Pools
  boot.zfs.extraPools = [ "tank" ];
  # Since we have a Non-ZFS root (ext4 boot drive) this prevents scanning for what does not exist
  boot.zfs.forceImportRoot = false;
  # ZFS requires a Host ID 
  networking.hostId = "c2dfeb62";
}