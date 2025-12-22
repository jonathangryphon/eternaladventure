{ config, pkgs, ... }:

{
  services.traefik.dynamicConfigOptions.http.middlewares = {
    dashboard-auth.basicAuth.users = [ "charity:$2y$05$7Lo84GNHeR5cahe7JajlaO0FW4RlsKMiF31dA2ZnJ1jHA8b.9cqA." ];
  };

  services.traefik.dynamicConfigOptions.http.routers.traefik = {
    rule = "Host(`traefik.eternaladventure.xyz`)";
    entryPoints = [ "websecure" ];
    service = "api@internal";
    tls.certResolver = "letsencrypt";
    middlewares = [ "dashboard-auth" ];
  };
}
