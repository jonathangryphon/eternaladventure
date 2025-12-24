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
        };
      };

      api = {
	dashboard = true;
	insecure = false; # don't even risk the true option, according to chatgpt
      };

      # so, turns out this is not neccessary when using dynamicConfigOptions 
      # unless I am manually dropping YAML files for Traefik, well, not as a file provider, docker still needed
      providers = {       
	docker = {
          endpoint = "unix:///run/podman/podman.sock";
          exposedByDefault = false;
	};
      };

      # ACME and HTTPS
      certificatesResolvers.letsencrypt.acme = {
        email = "eternaladventure@proton.me";
        storage = "${dataDir}/acme.json"; #acme still needs to know where to go inside StateDirectory despite it being declared
        httpChallenge.entryPoint = "web";
      };

      log.level = "INFO";
    };
  };

  # Ensure Podman socket is available at boot.
  # Traefik's docker provider connects via /run/podman/podman.sock
  # and may start before the socket exists without this.
  # may be unnecessary, we can try without. chatgpt is conflicted, says it should be ok, sort of.
  # systemd.services.traefik.wants = [ "podman.socket" ];

}
