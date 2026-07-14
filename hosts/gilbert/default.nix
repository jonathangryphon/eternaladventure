{ pkgs, ... }:

{
  imports = [ ./homebrew.nix ];

  nix.enable = false;
  
  networking.hostName = "Gilbert";

  security.pam.services.sudo_local.touchIdAuth = true;

  system.primaryUser = "jonathangryphon";
  system.defaults.screencapture.location = "~/testphotos/screenshots";
  
  system.defaults = {
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "Nlsv"; # list view
      ShowPathbar = true;
      ShowStatusBar = true;
    };
  };

  programs.zsh = {
    enable = true;
    shellInit = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    fastfetch
    btop
    cmatrix
    wireguard-tools
    smartmontools
    sops
    age
    sherlock
    exiftool
    asciiquarium
  ];

  system.stateVersion = 6;
}