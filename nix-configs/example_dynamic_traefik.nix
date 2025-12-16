{ config, ... }:

# So what the heck does this file do?
# Well, traefik uses "routers" to determine where external traffic goes. 
# These can be defined via a few different methods. Files, env variables, and labels.
# If I understand correctly, labels are container metadata, defined inside the container itself.
# So this "dynamic traefik" configuration file declaratively defines the files which traefik will use to route traffic to the various containers (aka services).
# The traefik service looks for and finds these files under /etc/traefik, thus the environment.etc.----- stuff

# AH HAH!!! So in Nix, the services.traefik.dynamicConfigOptions module automatically generates the dynamic files for us!!
# Which means I don't have to do the confusing environment.etc.blablablabla confusing stuff. It will be a bit cleaner.
# Oh, and then we can actually do the thing I sort of liked about labels, where the containers define their own trafficking. 
# So we can use the services.traefik.dynamicConfigOptions module in ente.nix basically to define the routing.
# Now, this may go against the whole pure modularity stuff, I'm unsure. 
# No.
# So, for a variety of reasons, using dynamicConfigOptions is just straight up ok. 
# It gets checked if written wrong for example because it's built native for Nixos. 
# You can "poll" it in order to get all the routing information on the device using the below. 
#	nixos-option services.traefik.dynamicConfigOptions
# It's all declarative and gets run at Nix build time as opposed to container run time. Etc..

# So, I will add a services.traefik.dynamicConfigOptions piece to all my apps which will define their routing within their own config file. 
# Traefik will somehow figure it out from there. 

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

  # Example Test YAML using Nix module
  services.traefik.dynamicConfigOptions = {
    http = {
      routers.ente = {
	rule = "Host(`test.eternaladventure.xyz`)";
	entryPoints = [ "websecure" ];
	service = "test";
	# middlewares = 
        tls.certResolver = "letsencrypt";
      };
    };
  };

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
            certResolver: letsencrypt
      services:
        headscale:
          loadBalancer:
            servers:
              - url: "http://localhost:${cfg.headscalePort}"
  '';
}

