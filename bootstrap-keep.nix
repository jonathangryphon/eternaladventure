{ lib, pkgs, sops-nix, ... }:
{
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = false;

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    vim git wget htop sops age
  ];

  imports = [
    ./modules/ssh.nix
    ./modules/traefik.nix
    ./users.nix
  ];

  system.stateVersion = "24.05";
}