{ config, pkgs, ... }:

let
  pool = "tank";
in
{

  # Mount pool root for simplified observability
  fileSystems."/tank" = {
    device = "tank";
    fsType = "zfs";
  };

  # Mount Ente storage
  fileSystems."/var/lib/ente" = {
    device = "${pool}/ente";
    fsType = "zfs";
  };

  # Mount Headscale storage
  fileSystems."/var/lib/headscale" = {
    device = "${pool}/headscales";
    fsType = "zfs";
  };

  # Mount Traefik storage
  fileSystems."/var/lib/traefik" = {
    device = "${pool}/traefik";
    fsType = "zfs";
  };

  # Mount Nextcloud or other self hosted general file storage solution

  # Optional: ZFS dataset properties
  #environment.etc."zfs-properties".text = ''
   # zfs set compression=lz4 ${pool}
    #zfs set atime=off ${pool}/photos
  #'';

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
#    autoImport.enable = true # this does't seem real according to search.nixos.org
  };
}
