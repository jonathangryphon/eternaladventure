{ config, pkgs, ... }:

{
  systemd.services.ente = {
    description = "Ente Photos Container";
    after = [ "network.target" ];
    wants = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.podman}/bin/podman run --rm -p 8080:80 entefm/ente:latest";
      Restart = "always";
      User = "admin"; # rootless
    };
    wantedBy = [ "multi-user.target" ];
  };
}


{ config, pkgs, lib, ... }:

let
  # Your domain for routing
  domain = "eternaladventure.xyz";

  # Port inside the container that Ente listens on
  enteInternalPort = 8081;
in
{
  ############################
  # Podman container for Ente
  ############################
  services.podman.containers.ente = {
    # Latest image from GitHub Container Registry
    image = "ghcr.io/ente-io/server:latest";

    # Restart automatically if the container stops
    restartPolicy = "always";

    # NO host port mapping
    # This container is internal-only; Traefik accesses it via the Podman socket
  };

  ############################
  # Traefik dynamic routing
  ############################
  services.traefik.dynamicConfigOptions = lib.mkMerge [
    # Preserve any existing dynamicConfigOptions from other services
    config.services.traefik.dynamicConfigOptions or {}

    # Add Ente-specific router and service
    {
      http = {
        routers.ente = {
          # Route traffic for ente.eternaladventure.xyz
          rule = "Host(`ente.${domain}`)";

          # Use HTTPS entry point
          entryPoints = [ "websecure" ];

          # Map to the internal service
          service = "ente";

          # TLS via Let's Encrypt
          tls.certResolver = "letsencrypt";
        };

        services.ente = {
          # Define the load balancer pointing to the internal container port
          loadBalancer = {
            servers = [
              { url = "http://127.0.0.1:${enteInternalPort}"; }
            ];
          };
        };
      };
    }
  ];
}

