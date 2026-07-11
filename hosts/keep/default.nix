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
        publicKey = "ux+nVl+PYXFWASdRiLHzBIl47pomj7i9tViMGghPXWE="; # fill
        allowedIPs = [ "10.100.0.2/32" ];
      }
      {
        publicKey = "SRAl4q1hX9tKFyiYejFqDI3fX7m2+J2cvr1hexKcYmI=";
        allowedIPs = [ "10.100.0.3/32" ];
      }
    ];
  };

  sops.secrets.wg-keep-key = {
    sopsFile = ../../secrets/keep.yaml;
    format = "yaml";
  };

  sops.age.keyFile = "/etc/nixos/secrets/age-keys.txt";
  
  # OPTIONS
  mySsh.port = 62024;

  system.stateVersion = "24.05";
}