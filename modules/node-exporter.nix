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

  # Only allow scraping from Prometheus's host (afabel) over the tailnet,
  # not the public internet. Adjust the CIDR/IP to afabel's actual tailscale IP.
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 9100 -s 100.64.0.4/32 -j nixos-fw-accept
  '';
}