{ config, lib, pkgs, ... }:
{
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "systemd"    # per-unit status — feeds your "service health" goal directly
      "filesystem"
      "diskstats"
      "netdev"
      "loadavg"
      "meminfo"
      "cpu"
      "thermal_zone"   # useful for lulu especially — Pi5 thermal throttling is real
    ];
    port = 9100;
    listenAddress = "0.0.0.0";   # bind to all interfaces; firewall/tailscale ACLs restrict actual reachability
    openFirewall = false;        # deliberately false — see note below
  };

  services.prometheus.exporters.zfs = {
    enable = true;
    port = 9134;
  };

  services.prometheus.exporters.smartctl = {
    enable = true;
  };

  services.prometheus.exporters.process = {
    enable = true;
    port = 9997;
    settings.process_names = [
      {
        name = "minecraft";
        cmdline = [ "java" ];
      }

      {
        name = "php-fpm";
        cmdline = [ "php-fpm" ];
      }
    ];
  };

  # Only allow scraping from Prometheus's host (afabel) over the tailnet,
  # not the public internet. Adjust the CIDR/IP to afabel's actual tailscale IP.
  networking.firewall.extraCommands = ''
    for port in 9100 9134 9633 9940 9997; do
      iptables -A nixos-fw -p tcp --dport $port -s 100.64.0.4/32 -j nixos-fw-accept
    done
  '';
}