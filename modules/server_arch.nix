{ config, lib, ... }:
let inherit (lib) mkOption types;
in {
  options.myServer = {
    dataRoot = mkOption {
      type = types.str;
      default = "/var/lib/services";
      description = "Root path for all service data directories.";
    };
  };
  
  options.myServer.runServices = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable service modules; flip only after data restore is verified";
  };

}