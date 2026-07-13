{ config, lib, pkgs, ... }:
{
  services.prometheus = {
    enable = true;
    port = 9090;

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "afabel.ts.eternaladventure.xyz:9100"
              "lulu.ts.eternaladventure.xyz:9100"
              "keep.ts.eternaladventure.xyz:9100"
            ];
          }
        ];
      }
      {
        job_name = "zfs";
        static_configs = [
          {
            targets = [
              "afabel.ts.eternaladventure.xyz:9134"
              "lulu.ts.eternaladventure.xyz:9134"
            ];
          }
        ];
      }
      {
        job_name = "minecraft";
        static_configs = [
          {
            targets = [ "afabel.ts.eternaladventure.xyz:9940" ];
            labels.server_name = "afabel";
          }
        ];
      }
      {
      job_name = "smartctl";
      static_configs = [
          { targets = [
              "afabel.ts.eternaladventure.xyz:9633"
              "lulu.ts.eternaladventure.xyz:9633"
          ];
          }
      ];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "grafana.eternaladventure.xyz";
        root_url = "https://grafana.eternaladventure.xyz";
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9090";
          isDefault = true;
        }
      ];
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.grafana = {
      rule = "Host(`grafana.eternaladventure.xyz`)";
      entryPoints = [ "websecure" ];
      service = "grafana-service";
      tls.certResolver = "letsencrypt";
    };
    services.grafana-service.loadBalancer.servers = [
      { url = "http://127.0.0.1:3000"; }
    ];
  };
}