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
    
    loadBalancer.server = [
      { url = "http://127.0.0.1:8080"; }
    ]; 
 };

  systemd.services.headscale.serviceConfig = {
    StateDirectory = "headscale";
  };

  # Traefik integration for networking/routing
  services.traefik.dynamicConfigOptions.http = {
    routers.headscale = {
      rule = "Host(`headscale.eternaladventure.xyz`)";
      entryPoints = [ "websecure" ];
      service = "headscale";
      tls.certResolver = "letsencrypt";
      # TODO: Headscale needs HTTP/2 disabled behind proxies???
      # middlewares = [ "headscale-headers" ];
  };
}

