{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap"; # remove brews/casks/taps not listed here
    };

    taps = [
      # "homebrew/cask-fonts"
    ];

    casks = [ # Fill in with GUI apps that aren't in nixpkgs
      "balenaetcher"
      "bitwarden"
      "cryptomator"
      "duckduckgo"
      "ente"
      "ente-auth"
      "firefox"
      "google-chrome"
      "joplin"
      "minecraft"
      "nextcloud"
      "orion"
      "proton-drive"
      "protonvpn"
      "qbittorrent"
      "signal"
      "spotify"
      "utm"
      "vlc"
      "vscodium"
      "whatsapp"
      "tailscale-app"
    ];

    masApps = {
      # "Some App" = 123456789; # requires `mas` brew above + signed into App Store
    };
  };
}
