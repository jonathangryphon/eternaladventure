{ config, pkgs, lib, ... }:
{
  imports = [
    ../../modules/traefik_passthrough.nix
    ../../modules/traefik.nix
    ../../modules/users/core.nix
    ../../modules/ssh.nix
  ];

  # BOOT
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub.enable = lib.mkForce true;
  boot.loader.grub.efiSupport = lib.mkForce false;
  # boot.loader.grub.device = "/dev/vda";
  
  time.timeZone = "America/Los_Angeles";

  systemd.network.wait-online.anyInterface = true;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
  
  networking.hostName = "keep";
  networking.firewall.allowedUDPPorts = [ 51820 ]; # wireguard
  networking.firewall.allowedTCPPorts = [ 33333 62022 62023 ]; # minecraft, afabel, lulu 

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/run/secrets/wg-keep-key";
    peers = [
      {
        publicKey = "iFiR6mp6Ldr/SBH2lLK05yETBm5Fbq2pD9di4Ai4BnE=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
      {
        publicKey = "SRAl4q1hX9tKFyiYejFqDI3fX7m2+J2cvr1hexKcYmI=";
        allowedIPs = [ "10.100.0.3/32" ];
      }
      {
        publicKey = "Gv1GYrjYO/SlETPsrB90/qscR5NYpiiW4Z5tKPPVOBI=";
        allowedIPs = [ "10.100.0.7/32" ];
      }      
    ];
  };

  # MAIL SERVER FORWARDING VIA NAT
  networking.nftables.ruleset = ''
    table inet nat {
      chain prerouting {
        type nat hook prerouting priority -100;
        tcp dport { 25, 465, 587, 993 } dnat to 10.100.0.2
      }
      chain postrouting {
        type nat hook postrouting priority 100;
        ip saddr 10.100.0.0/24 masquerade
      }
    }
  '';
  networking.nat.enable = true; # or boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  sops.secrets.wg-keep-key = {
    sopsFile = ../../secrets/keep.yaml;
    format = "yaml";
  };

  sops.age.keyFile = "/etc/nixos/secrets/age-keys.txt";
  
  # OPTIONS
  mySsh.port = 62024;

  system.stateVersion = "24.05";
}