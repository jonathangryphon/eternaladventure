{ config, pkgs, ... }:

{
  services.traefik.dynamicConfigOptions.http.routers.traefik = {
    rule = "Host(`traefik.eternaladventure.xyz`)";
    entryPoints = [ "websecure" ];
    service = "api@internal";
    tls.certResolver = "letsencrypt";
  };
}
