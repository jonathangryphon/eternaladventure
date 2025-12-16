{ config, pkgs, lib, ... }:

let
  dataDir = "/var/lib/traefik";
in
{
  services.traefik = {
    enable = true;

    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
          };
        };

        websecure = {
          address = ":443";
        };
      };

      api = {
	dashboard = true;
	insecure = true; #TEMPORARY - internal only

      providers.file = {
        directory = "${dataDir}/dynamic";
        watch = true;
      };

      certificatesResolvers.letsencrypt.acme = {
        email = "eternaladventure@proton.me";
        storage = "${dataDir}/acme.json";
        httpChallenge.entryPoint = "web";
      };

      log.level = "INFO";
    };
  };

  environment.etc."traefik/dynamic/.keep".text = "";

  systemd.services.traefik.serviceConfig = {
    StateDirectory = "traefik";
  };
}

