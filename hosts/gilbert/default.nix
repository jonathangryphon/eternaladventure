{ pkgs, ... }:

{
  nix.enable = false;
  
  networking.hostName = "Gilbert";

  security.pam.services.sudo_local.touchIdAuth = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    fastfetch
    btop
  ];

  system.stateVersion = 6;
}