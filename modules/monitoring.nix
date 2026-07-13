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
              "afabel.ts.eternaladventure.xyz:9100"   # adjust to your actual MagicDNS suffix
              "lulu.ts.eternaladventure.xyz:9100"
              "keep.ts.eternaladventure.xyz:9100"
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
        http_addr = "127.0.0.1";   # only local — fronted by traefik, same pattern as headscale
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
      # dashboards can be added here later, pointing at a directory of JSON files
      # dashboards.settings.providers = [ ... ];
    };
  };

  # traefik router — same pattern as headscale on afabel
  services.traefik.dynamicConfigOptions.http = {
    routers.grafana = {
      rule = "Host(`grafana.eternaladventure.xyz`)";
      entryPoints = [ "websecure" ];
      service = "grafana-service";
      tls.certResolver = "letsencrypt";   # match whatever afabel's other routers actually use
    };
    services.grafana-service.loadBalancer.servers = [
      { url = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}" }
    ];
  };
}