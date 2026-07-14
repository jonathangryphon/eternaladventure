{ pkgs, ... }:

{
  nix.enable = false;
  
  networking.hostName = "Gilbert";

  security.pam.enableSudoTouchIdAuth = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    fastfetch
    btop
  ];

  system.stateVersion = 6;
}