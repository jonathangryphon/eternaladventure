{ config, pkgs, ... }:
{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    https = true;
    hostName = "nextcloud.eternaladventure.xyz";
    config = {
      adminpassFile = TODO;
      dbtype = "sqlite";
    };
    dataDir = "/tank/services/nextcloud";
  };
}
