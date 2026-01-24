{ pkgs, lib, ... }:

{
  environment.systemPackages = [
    pkgs.papermcServers.papermc-1_21_9;
  ]

  services.minecraft-server = {
    enable = true;
    eula = true;
    declarative = true;
    openFirewall = true;

    package = pkgs.papermcServers.papermc-1_21_9;
    dataDir = "/tank/services/minecraft-server";

    serverProperties = {
        minecraft-server.port = 25655;
    }
  };
  
  services.traefik.dynamicConfigOptions.http.routers.minecraft-server = {
    rule = "Host(`minecraft.eternaladventure.xyz`)";
    entryPoints = [ "websecure" ];
    service = "minecraft-server";
    tls.certResolver = "letsencrypt";
  };

  services.traefik.dynamicConfigOptions.http.services.minecraft-server = {
    loadBalancer.servers = [
      { url = "http://127.0.0.1:25655"; }
    ];
  };
}