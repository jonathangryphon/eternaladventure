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
      # unless I am manually dropping YAML files for Traefik, well, not as a file provider, docker still>
      # and with that in mind, this is causing all the weird permission errors that pop up
      # but I do think I need to set it to false, just not underneath staticConfigOptions
      # providers = {       
	      # docker = {
          # endpoint = "unix:///run/podman/podman.sock";
          # exposedByDefault = false;
	      # };
      # };

      # ACME and HTTPS
      certificatesResolvers.letsencrypt.acme = {
        email = "eternaladventure@proton.me";
        storage = "${dataDir}/acme.json"; #acme still needs to know where to go inside StateDirectory de>
        httpChallenge.entryPoint = "web";
        # Server for testing purposes
        # Commenting out the caServer line below which links the staging platform is sufficient
        # NixOS and Traefik will auto move to the prod certs now
        # Revert and uncomment when testing other services, or specify them somehow
        # caServer = "https://acme-staging-v02.api.letsencrypt.org/directory";
      };

      accessLog = { }; # enabled
      log.level = "INFO";
    };
  };

  # Ensure Podman socket is available at boot.
  # Traefik's docker provider connects via /run/podman/podman.sock
  # and may start before the socket exists without this.
  # may be unnecessary, we can try without. chatgpt is conflicted, says it should be ok, sort of.
  # systemd.services.traefik.wants = [ "podman.socket" ];

}
