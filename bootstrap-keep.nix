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

  # USERS
  users.mutableUsers = false; # users managed fully by nixos

  users.users.charity = {
    isNormalUser = true;
    description = "primary Admin user";
    extraGroups = [ "wheel" ]; # sudo access
  };

  users.users.breakglass = {
    isNormalUser = true;
    description = "break glass account for emergency remediation";
    extraGroups = [ "wheel" ]; # sudo access
  };

  services.openssh = {
      enable = true;
      ports = [ 62022 ]; # security through obscurity to avoid default port 22 scanning via bots

      settings = {
        PasswordAuthentication = false;
        PubkeyAuthentication = true; # this is the default, but declaring it expresses code intent
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "charity" "breakglass" "syncoid" ];
      };
    };
  
  networking.firewall.allowedTCPPorts = [ 62022 ]; # open port for ssh
  
  # Associate SSH keys with users
  users.users.charity.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHawf4YO7tfG/BkWfw0E+aQRThKTIsGjXSwDBfQK/VGF charity@macbook"
  ];

  users.users.breakglass.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFGPtcNoxFq+KnnCvt5xmBAOfzLXWul3i0MmOA8W/FXl breakglass@macbook"
  ];  

  imports = [
    ./modules/traefik.nix
  ];

  system.stateVersion = "24.05";
}