{ config, ... }:

let
  dynDir = "/var/lib/traefik/dynamic";
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

