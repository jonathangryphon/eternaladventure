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
    dock = {
      persistent-apps = [
        "Applications/Safari.app"
        "Applications/Orion.app"
        "Applications/DuckDuckGo.app"
        "Applications/Firefox.app"
        "Applications/Spotify.app"
        "Applications/Signal.app"
        "Applications/Whatsapp.app"
        "Applications/Ente Auth.app"
        "Applications/Terminal.app"
        "Applications/Messages.app"
        "Applications/VSCodium.app"
        "Applications/Joplin.app"
      ];
      persistent-others = [ ];
      autohide = true;
      show-recents = false;
    };
  };

  # Safari default search engine + default browser (requires `duti` in systemPackages)
  system.activationScripts.postActivation.text = ''
    sudo -u jonathangryphon defaults write com.apple.Safari SearchProviderShortName -string "DuckDuckGo"
  '';

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
    duti
  ];

  system.stateVersion = 6;
}