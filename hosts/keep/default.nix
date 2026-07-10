{ config, pkgs, lib, ... }:
{
  imports = [
    # disko takes care of this: ./hardware-rosalina.nix
    ../../modules/traefik_passthrough.nix
    ../../modules/traefik.nix
    ../../modules/users/core.nix
    ../../modules/ssh.nix
    ../../modules/services/headscale-server.nix
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
  networking.firewall.allowedTCPPorts = [ 33333 ]; # minecraft custom port

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/run/secrets/wg-keep-key";
    peers = [{
      publicKey = "ux+nVl+PYXFWASdRiLHzBIl47pomj7i9tViMGghPXWE="; # fill
      allowedIPs = [ "10.100.0.2/32" ];
    }];
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