{ config, pkgs, ... }:
{

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
    # autoSnapshot.enable = true; # the pi is just a backup host
  };

  services.syncoid = {
    enable = true;
    commonArgs = [ "--debug" ];
    commands = {
      "tank/services" = {
        source = "syncoid@Afabel:tank/services";  # or IP address
        target = "backup/main"; # whatever dataset on the Pi
        recursive = true; # this covers all datasets beneath services
        extraArgs = [ "--no-sync-snap" "--sshport 62022" ];  # let sanoid own snapshots, syncoid just replicates
      };
    };
  };
}
