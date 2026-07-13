{ config, pkgs, lib, ... }:

let
  dataDir = "/var/lib/traefik";
in
{
  services.traefik = {
    enable = true;
    dataDir = dataDir;

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
          transport.respondingTimeouts = {
            readTimeout = "3600s";
            writeTimeout = "3600s";
            idleTimeout = "3600s";
          };
        };
      };

      api = {
	      dashboard = true;
	      insecure = false;
      };

      # ACME and HTTPS
      certificatesResolvers.letsencrypt.acme = {
        email = "eternaladventure@proton.me";
        storage = "${dataDir}/acme.json"; # points directly to acme.json
        # httpChallenge.entryPoint = "web";
        tlsChallenge = true;
        caServer = "https://acme-staging-v02.api.letsencrypt.org/directory"; # used for testing new services
      };

      accessLog = { }; # enabled
      log.level = "DEBUG";
    };
  };
}
