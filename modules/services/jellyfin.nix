{ config, pkgs, ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = false;   # traefik fronts it; no direct public exposure needed
    dataDir = "${config.myServer.dataRoot}/jellyfin";
  };

  users.groups.media = {};
  users.users.jellyfin.extraGroups = [ "media" ];

  systemd.tmpfiles.rules = [
    "d /tank/services/media 2775 charity media -"
  ];
 
  # Traefik Required Bits — same pattern as nextcloud/grafana
  services.traefik.dynamicConfigOptions.http.routers.jellyfin = {
    rule = "Host(`jellyfin.eternaladventure.xyz`)";
    entryPoints = [ "websecure" ];
    service = "jellyfin-service";
    tls.certResolver = "letsencrypt";
  };
  services.traefik.dynamicConfigOptions.http.services.jellyfin-service.loadBalancer.servers = [
    { url = "http://127.0.0.1:8096"; }   # jellyfin's default port
  ];
}