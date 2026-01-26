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
    };
  };
}
