{ config, pkgs, ... }:

let
  pool = "tank";
in
{
  fileSystems."/tank/photos" = {
    device = "${pool}/photos";
    fsType = "zfs";
  };
  fileSystems."/tank/databases" = {
    device = "${pool}/databases";
    fsType = "zfs";
  };

  # Optional: ZFS dataset properties
  environment.etc."zfs-properties".text = ''
    zfs set compression=lz4 ${pool}
    zfs set atime=off ${pool}/photos
  '';
}
