{config, pkgs, lib,  ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./pi5-configtxt.nix
    ../../modules/zfs/syncoid-pull.nix
    ../../modules/wifi.nix  
  ];

  ############################
  # Boot / ZFS
  ############################
  boot.kernelModules = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "backup" ];
  boot.zfs.forceImportRoot = false;

  networking.hostId = "d2dfeb62";
  nix.settings.trusted-users = [ "root" "charity" ];

  ############################
  # Custom options
  ############################
  mySsh.port = 62023;
  myServer.dataRoot = "/backup/main";
  ############################
  # Host & Timezone
  ############################
  networking.hostName = "Lulu";
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
	
  ############################
  # Security
  ############################
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false; # users do not have pws, only ssh keys for auth

  ############################
  # Nix
  ############################
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  ############################
  # Packages
  ############################
  environment.systemPackages = with pkgs; [
    # Core CLI
    vim git wget btop neofetch

    # Secrets
    sops age

    # ZFS backup (sanoid/syncoid pipeline)
    sanoid pv mbuffer lzop zstd
  ];

  ############################
  # WireGuard — direct tunnel to keep, independent of afabel
  ############################
  sops.secrets.wg-lulu-key = {
    sopsFile = ../../secrets/lulu.yaml;
    format = "yaml";
  };

  networking.wireguard.interfaces.wg1 = {   # wg1, not wg0 — avoid clash if Lulu ever also gets an afabel-facing tunnel later
    ips = [ "10.100.0.3/24" ];
    privateKeyFile = "/run/secrets/wg-lulu-key";
    peers = [{
      publicKey = "0iQVcRdUygTb1f8afgPXnrzj1CiDMUH3LP/JURY9LQY=";   # 0iQVcRdUygTb1f8afgPXnrzj1CiDMUH3LP/JURY9LQY=
      endpoint = (import /etc/nixos-local/wg-peers.nix).endpoint;  # same local-only pattern as afabel
      allowedIPs = [ "10.100.0.1/32" ];
      persistentKeepalive = 25;
    }];
  };

  ############################
  # sops-nix-lulu pin note
  ############################
  # sops-nix-lulu intentionally separate from main sops-nix — must match
  # nixpkgs-lulu (rpi flake's pinned nixpkgs), not main nixpkgs. Not mergeable.

  ############################
  # auto-upgrade — deferred, see planned modules/common/auto-upgrade.nix
  # (allowReboot=true removed on purpose — don't let a headless ZFS/WG
  # box reboot itself unattended; revisit with allowReboot=false design)
  ############################

  ############################
  # First NixOS version installed
  ############################
  system.stateVersion = "25.11";
}
