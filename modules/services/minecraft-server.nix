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
        server-port = 33333;
    }
  };
}
