{ config, ... }:

let
  dynDir = "/var/lib/traefik/dynamic";
in
{
  systemd.tmpfiles.rules = [
    "d ${dynDir} 0750 traefik traefik -"
  ];

  environment.etc."traefik/dynamic/test.yaml".text = ''
    http:
      routers:
        test:
          rule: "Host(`test.afabel.net`)"
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
}

