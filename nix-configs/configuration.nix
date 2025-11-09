{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./zfs.nix
    ./podman-containers.nix
    ./services/ente.nix
    ./services/traefik.nix
    ./services/headscale.nix
  ];

	############################
  # Host & Timezone
  ############################
  networking.hostName = "KingJalyn";
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
	
	############################
  # Security
  ############################
  security.autoUpgrade.enable = true;
  security.sudo.wheelNeedsPassword = true;
}