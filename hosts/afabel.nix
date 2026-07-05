{ config, pkgs, lib, ... }:
{
  imports = [ 
    ../hardware-configuration.nix
    ../modules/restic.nix
  ];

  networking.hostName = "Afabel"; # cuz driven by eternity

  # OPTIONS
  myServer.dataRoot = "/tank/services"; # modules/server_arch.nix option for centralizing service data directory definitions
  # ZFS 
  boot.zfs.extraPools = [ "tank" ];
  boot.zfs.forceImportRoot = false; # root drive is not zfs, only ext4
  networking.hostId = "c2dfeb62"; # unique host ID required by zfs

  # DDNS
  services.oink.enable = true;

  # "KEEP" PROXY
  networking.wireguard.interfaces.wg0.peers = [{
    publicKey = "KEEP_WG_PUBKEY"; # fill
    endpoint = "KEEP_PUBLIC_IP:51820";
    allowedIPs = [ "10.100.0.1/32" ];
    persistentKeepalive = 25;
  }];
}