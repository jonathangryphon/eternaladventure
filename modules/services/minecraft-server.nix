{ pkgs, lib, ... }:

{
  environment.systemPackages = [
    pkgs.papermcServers.papermc-1_21_10;
  ]

  services.minecraft-server = {
    enable = true;
    eula = true;
    declarative = true;
    openFirewall = true;

    package = pkgs.papermcServers.papermc-1_21_9;
    dataDir = "/tank/services/minecraft-server";

    javaOpts = "-Xms8G -Xmx8G"; 

    serverProperties = {
        server-port = 33333;
    }
  };
}
