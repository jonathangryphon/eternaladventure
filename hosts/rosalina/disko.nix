# /etc/nixos/hosts/disks/rosalina-disk.nix
{ ... }:
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/sda";  # verify with lsblk on VPS
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02";  # BIOS boot partition
          };
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          swap = {
            size = "8G";
            content = { 
              type = "swap"; 
              randomEncryption = true; 
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
        "local/root" = {
          type = "zfs_fs";
          options.mountpoint = "/";
        };
        "local/nix" = {
          type = "zfs_fs";
          options.mountpoint = "/nix";
        };
        "services" = {
          type = "zfs_fs";
          options = {
            mountpoint = "/var/lib/services";
            encryption = "aes-256-gcm";
            keyformat = "passphrase";
            keylocation = "prompt";
          };
        };
        "services/nextcloud" = { type = "zfs_fs"; };
        "services/postgresql" = { type = "zfs_fs"; };
        "services/ente" = { type = "zfs_fs"; };
        "services/garage" = { type = "zfs_fs"; };
        "services/minecraft-server" = { type = "zfs_fs"; };
        "services/traefik" = { type = "zfs_fs"; };
      };
    };
  };
}