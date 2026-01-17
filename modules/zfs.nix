{ config, pkgs, ... }:
{

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
    autoSnapshot.enable = true;
  };
}
