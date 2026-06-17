{ config, pkgs, lib, ... }:
{
  imports = [ ./hardware-rosalina.nix ];

  networking.hostName = "Rosalina";
  myServer.dataRoot = "/var/lib/services";

  # Static subdomain — no dynamic DNS needed (VPS IPs don't change)
  services.oink.enable = false;

  # No ZFS pool on VPS
  myServer.zfsPoolReady = false;

  # Open ports for remote access
  networking.firewall.allowedTCPPorts = [ 62022 80 443 ];

  # Traefik ACME — use a separate cert resolver or staging for VPS
  # to avoid hitting Let's Encrypt rate limits on your real domain
}
}