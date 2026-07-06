{ config, pkgs, lib, ... }:
{
  imports = [
    # disko takes care of this: ./hardware-rosalina.nix
    # ../disks/keep-disk.nix
  ];

  # BOOT
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub.enable = lib.mkForce true;
  boot.loader.grub.efiSupport = lib.mkForce false;
  boot.loader.grub.device = "/dev/vda";

  systemd.network.wait-online.anyInterface = true;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
  
  networking.hostName = "keep";
  networking.firewall.enable = true;
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.firewall.allowedTCPPorts = [ 80 443 33333 ];

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/run/secrets/wg-keep-key";
    peers = [{
      publicKey = "iFiR6mp6Ldr/SBH2lLK05yETBm5Fbq2pD9di4Ai4BnE="; # fill
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
}