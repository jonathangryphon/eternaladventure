disko.devices = {
  disk = {
    main = {
      device = "/dev/sda"; # confirm in rescue mode
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = { type = "filesystem"; format = "vfat"; mountpoint = "/boot"; };
          };
          zfs = {
            size = "100%";
            content = { type = "zfs"; pool = "rpool"; };
          };
        };
      };
    };
    tank = {
      device = "/dev/sdb"; # confirm in rescue mode — Hetzner volume
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          zfs = {
            size = "100%";
            content = { type = "zfs"; pool = "tank"; };
          };
        };
      };
    };
  };

  zpool = {
    rpool = {
      type = "zpool";
      options = { ashift = "12"; };
      rootFsOptions = {
        encryption = "aes-256-gcm";
        keyformat = "passphrase";
        keylocation = "prompt";
        compression = "zstd";
        canmount = "off";
        mountpoint = "none";
      };
      datasets = {
        root = { type = "zfs_fs"; mountpoint = "/"; };
      };
    };

    tank = {
      type = "zpool";
      options = { ashift = "12"; };
      rootFsOptions = {
        encryption = "aes-256-gcm";
        keyformat = "passphrase";
        keylocation = "prompt"; # same passphrase prompt, or separate — decide below
        compression = "zstd";
        canmount = "off";
        mountpoint = "none";
      };
      datasets = {
        services                         = { type = "zfs_fs"; options.mountpoint = "/tank/services"; };
        "services/garage"                = { type = "zfs_fs"; options.mountpoint = "/tank/services/garage"; };
        "services/hermes"                = { type = "zfs_fs"; options.mountpoint = "/tank/services/hermes"; };
        "services/hermes-notes"          = { type = "zfs_fs"; options.mountpoint = "/tank/services/hermes-notes"; };
        "services/minecraft-server"      = { type = "zfs_fs"; options.mountpoint = "/tank/services/minecraft-server"; };
        "services/nextcloud"             = { type = "zfs_fs"; options.mountpoint = "/tank/services/nextcloud"; };
        "services/postgresql"            = { type = "zfs_fs"; options.mountpoint = "/tank/services/postgresql"; };
      };
    };
  };
};