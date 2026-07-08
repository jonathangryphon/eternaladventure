{ lib, pkgs, sops-nix, ... }:
{
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = false;

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    vim git wget htop sops age
  ];
  
  networking.firewall.allowedTCPPorts = [ 62022 ]; # open port for ssh 

  sops.age.keyFile = "/etc/nixos/secrets/age-keys.txt";

  imports = [
    ./modules/traefik.nix
    ./modules/users/core.nix
    ./modules/ssh.nix
  ];

  system.stateVersion = "24.05";
}