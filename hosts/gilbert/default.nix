{ pkgs, ... }:

{
  imports = [ ./homebrew.nix ];

  nix.enable = false;
  networking.hostName = "Gilbert";

  security.pam.services.sudo_local.touchIdAuth = true;

  system.primaryUser = "charity";
  system.defaults.screencapture.location = "~/screenshots";
  
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
        "/System/Applications/Utilities/Terminal.app"
        "/System/Applications/Messages.app"
        "Applications/VSCodium.app"
        "Applications/Joplin.app"
      ];
      persistent-others = [ ];
      autohide = true;
      show-recents = false;
      wvous-tl-corner = 1; # 1 = disabled
      wvous-tr-corner = 1;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;      
    };
    NSGlobalDomain = {
      AppleICUForce24HourTime = true;
    };
    menuExtraClock = {
      Show24Hour = true;
      ShowDate = 1; # always show date
      DateFormat = "EEE d MMM"; # e.g. "Sun 19 Jul"
    };    
  };

  programs.zsh = {
    enable = true;
    shellInit = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
      alias vim="nvim -u /etc/nvim-minimal.vim"
      alias cat="bat"
    '';
  };

  environment.etc."nvim-minimal.vim".text = ''
    syntax on
    set number
    set tabstop=2
    set shiftwidth=2
    set expandtab
  '';

  environment.etc."nanorc".text = ''
    include "${pkgs.nanorc}/share/nanorc/*.nanorc"
    set linenumbers
    set tabsize 2
  '';

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
    bat
    neovim
    nanorc
  ];

  system.stateVersion = 6;
}