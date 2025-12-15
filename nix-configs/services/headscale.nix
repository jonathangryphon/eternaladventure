{ config, pkgs, lib, ... }:

{
  services.headscale = {
    enable = true;

    settings = {
      server_url = "https://headscale.eternaladventure.xyz";

      listen_addr = "127.0.0.1:8080";

      database = {
        type = "sqlite";
        sqlite = {
          path = "/var/lib/headscale/db.sqlite";
        };
      };

      log.level = "info";
    };
  };

  systemd.services.headscale.serviceConfig = {
    StateDirectory = "headscale";
  };
}

