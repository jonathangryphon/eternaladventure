{ pkgs, ... }:

{
  nix.enable = false;
  
  networking.hostName = "Gilbert";

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    fastfetch
    btop
  ];

  system.stateVersion = 6;
}