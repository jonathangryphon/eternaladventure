# /etc/nixos/hosts/disks/rosalina-local-disk.nix
{ ... }:
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/vda";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "tank";
            };
          };
        };
      };
    };
    zpool.tank = {
      type = "zpool";
      rootFsOptions = {
        compression = "zstd";
        "com.sun:auto-snapshot" = "false";
        mountpoint = "none";
      };
      datasets = {
        "local/root"    = { type = "zfs_fs"; options.mountpoint = "/"; };
        "local/nix"     = { type = "zfs_fs"; options.mountpoint = "/nix"; };
        "local/persist" = { type = "zfs_fs"; options.mountpoint = "/persist"; };
        "services" = {
          type = "zfs_fs";
          options.mountpoint = "/var/lib/services";
        };
        "services/nextcloud"        = { type = "zfs_fs"; };
        "services/postgresql"       = { type = "zfs_fs"; };
        "services/ente"             = { type = "zfs_fs"; };
        "services/garage"           = { type = "zfs_fs"; };
        "services/minecraft-server" = { type = "zfs_fs"; };
        "services/traefik"          = { type = "zfs_fs"; };
      };
    };
  };
}