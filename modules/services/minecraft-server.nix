{ pkgs, lib, ... }:

{
  services.minecraft-server = {
    enable = true;
    eula = true;
    declarative = true;
    openFirewall = true;

    package = pkgs.papermcServers.papermc-1_21_10;
    dataDir = "/tank/services/minecraft-server";

    jvmOpts = "-Xms8G -Xmx8G"; 

    serverProperties = {
        server-port = 33333;
        online-mode = false; # (disabled so others can join without mojang ver.)
        motd = "§2§l§oThe Eternal Adventure Server§r\n§aBased in Texas. Hosted by Jonathan. :D ";
        view-distance = 32;
        enable-rcon = true;
        "rcon.password" = "whatever123";
        "rcon.port" = 33334;
    };
  };
  
  services.traefik.dynamicConfigOptions.http.routers.dynmap = {
    rule = "Host(`map.eternaladventure.xyz`)";
    entryPoints = [ "websecure" ];
    service = "dynmap";
    tls.certResolver = "letsencrypt";
  };

  services.traefik.dynamicConfigOptions.http.services.dynmap-service = {
    loadBalancer.servers = [
      { url = "http://127.0.0.1:8123"; }
    ];
  };
}
