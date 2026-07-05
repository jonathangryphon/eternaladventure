{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "keep";
  networking.firewall.enable = true;
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.firewall.allowedTCPPorts = [ 80 443 33333 ];

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/run/secrets/wg-keep-key";
    peers = [{
      publicKey = "AFABEL_WG_PUBKEY"; # fill
      allowedIPs = [ "10.100.0.2/32" ];
    }];
  };

  services.traefik = {
    enable = true;
    staticConfigOptions = {
      entryPoints.web.address = ":80";
      entryPoints.websecure.address = ":443";
      entryPoints.mc.address = ":33333";
    };
    dynamicConfigOptions.tcp = {
      routers = {
        https-passthrough = {
          entryPoints = [ "websecure" ];
          rule = "HostSNI(`*`)";
          service = "home-https";
          tls.passthrough = true;
        };
        http-passthrough = {
          entryPoints = [ "web" ];
          rule = "HostSNI(`*`)";
          service = "home-http";
        };
        mc-passthrough = {
          entryPoints = [ "mc" ];
          rule = "HostSNI(`*`)";
          service = "mc-home";
        };
      };
      services = {
        home-https.loadBalancer.servers = [{ address = "10.100.0.2:443"; }];
        home-http.loadBalancer.servers  = [{ address = "10.100.0.2:80"; }];
        mc-home.loadBalancer.servers    = [{ address = "10.100.0.2:33333"; }];
      };
    };
  };

  sops.secrets.wg-keep-key = {
    sopsFile = ../secrets/keep.yaml;
    format = "yaml";
  };

  system.stateVersion = "24.05"; # match channel
}