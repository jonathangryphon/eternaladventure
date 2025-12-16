{ config, ... }:

# So what the heck does this file do?
# Well, traefik uses "routers" to determine where external traffic goes. 
# These can be defined via a few different methods. Files, env variables, and labels.
# If I understand correctly, labels are container metadata, defined inside the container itself.
# So this "dynamic traefik" configuration file declaratively defines the files which traefik will use to route traffic to the various containers (aka services).
# The traefik service looks for and finds these files under /etc/traefik, thus the environment.etc.----- stuff

let
  dynDir = "/var/lib/traefik/dynamic";
  cfg.domain = "eternaladventure.xyz";
in
{
  systemd.tmpfiles.rules = [
    "d ${dynDir} 0750 traefik traefik -"
  ];

  # Generate Test YAML
  environment.etc."traefik/dynamic/test.yaml".text = ''
    http:
      routers:
        test:
          rule: "Host(`test.eternaladventure.xyz`)"
          entryPoints: [ websecure ]
          service: test
          tls:
            certResolver: letsencrypt

      services:
        test:
          loadBalancer:
            servers:
              - url: "http://127.0.0.1:65535"
  '';

  # Generate Headscale YAML
  environment.etc."traefik/dynamic/headscale.yml".text = ''
    http:
      routers:
        headscale:
          rule: "Host(`headscale.${cfg.domain}`)"
          entryPoints:
            - websecure
          service: headscale
          tls:
            certResolver: myresolver
      services:
        headscale:
          loadBalancer:
            servers:
              - url: "http://localhost:${cfg.headscalePort}"
  '';
}

