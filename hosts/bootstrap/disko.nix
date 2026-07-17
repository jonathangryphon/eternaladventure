# /etc/nixos/hosts/disks/rosalina-disk.nix
{ config, ... }:
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
            type = "EF02";
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

    disk.data = {
      type = "disk";
      device = "/dev/sdb";  # verify with lsblk once volume attached
      content = {
        type = "gpt";
        partitions = {
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "data";
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
      };
    };

    zpool.data = {
      type = "zpool";
      rootFsOptions = {
        compression = "zstd";
        "com.sun:auto-snapshot" = "false";
        mountpoint = "none";
      };
      datasets = {
        "services" = {
          type = "zfs_fs";
          options = {
            mountpoint = config.myServer.dataRoot;
            encryption = "aes-256-gcm";
            keyformat = "passphrase";
            keylocation = "file:///run/secrets/zfs-services-key";
            atime = "off";
          };
        };
        "services/nextcloud" = { type = "zfs_fs"; };
        "services/postgresql" = {
          type = "zfs_fs";
          options.recordsize = "8K";
        };
        "services/ente" = { type = "zfs_fs"; };
        "services/garage" = { type = "zfs_fs"; };
        "services/minecraft-server" = { type = "zfs_fs"; };
        "services/traefik" = { type = "zfs_fs"; };
        "services/jellyfin" = {
          type = "zfs_fs";
          options = {
            recordsize = "1M";
            logbias = "throughput";
          };
        };
        "services/media" = {
          type = "zfs_fs";
          options = {
            recordsize = "1M";
            compression = "off";
            logbias = "throughput";
          };
        };
      };
    };
  };
}