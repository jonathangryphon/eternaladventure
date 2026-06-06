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
    };
  };
}
