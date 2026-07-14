{ pkgs, ... }:

{
  nix.enable = false;
  
  networking.hostName = "Gilbert";

  security.pam.services.sudo_local.touchIdAuth = true;

  system.primaryUser = "jonathangryphon";
  system.defaults.screencapture.location = "~/testphotos/screenshots";

  homebrew.enable = true;
  homebrew.casks = [
    "wireshark"
  ];
  
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    fastfetch
    btop
  ];

  system.stateVersion = 6;
}