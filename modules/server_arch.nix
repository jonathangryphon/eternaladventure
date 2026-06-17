{ config, lib, ... }:
let inherit (lib) mkOption types;
in {
  options.myServer = {
    dataRoot = mkOption {
      type = types.str;
      default = "/var/lib/services";
      description = "Root path for all service data directories.";
    };
    zfsPoolReady = mkOption {
      type = types.bool;
      default = false;
      description = "Whether the ZFS tank pool is available.";
    };
  };
}