{ config, pkgs, lib, ... }:
{
  imports = [
    # disko takes care of this: ./hardware-rosalina.nix
    # ../disks/keep-disk.nix
    ../modules/traefik_passthrough.nix
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
      publicKey = "ux+nVl+PYXFWASdRiLHzBIl47pomj7i9tViMGghPXWE="; # fill
      allowedIPs = [ "10.100.0.2/32" ];
    }];
  };

  sops.secrets.wg-keep-key = {
    sopsFile = ../secrets/keep.yaml;
    format = "yaml";
  };
}