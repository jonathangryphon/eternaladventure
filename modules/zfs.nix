{ config, pkgs, ... }:
{

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  services.syncoid = { # pi uses syncoid user to pull backups
    enable = true;
    commonArgs = [ "--debug" ];
  };

  services.sanoid = {
    enable = true;
    extraArgs = [ "--debug" ];
    datasets = {
      "tank/services" = {
        recursive = true; # this covers all datasets beneath services
        hourly = 24;
        daily = 7;
        weekly = 4;
        monthly = 3;
        autosnap = true;
        autoprune = true;
      };
    };
  };
}
