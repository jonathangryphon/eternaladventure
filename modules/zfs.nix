{ config, pkgs, ... }:
{

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
    # autoSnapshot.enable = true; # replaced by sanoid below
  };

  services.syncoid = { # creates the syncoid user which the pi can use to remote in for backup pulls
    enable = true;
  };

  services.sanoid = {
    enable = true;
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
