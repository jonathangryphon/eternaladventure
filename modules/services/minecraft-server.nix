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
        motd = "\u00a7aRunning out of Texas. \u263b\u00a7r\n\u00a7aFrom Jonathan. \u2600";
        view-distance = 32;
    };
  };
}
