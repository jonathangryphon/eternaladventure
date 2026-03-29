{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [
      config.sops.secrets.home-wifi.path
      config.sops.secrets.nano-wifi.path
      config.sops.secrets.koshka-wifi.path
    ];
    profiles = {
      "home-wifi" = {
        connection = {
          id = "home-wifi";
          permissions = "";
          type = "wifi";
          autoconnect = true;
          interfaceName = "wlan0"; # adjust to your interface
        };
        ipv4 = { method = "auto"; };
        ipv6 = { method = "auto"; addrGenMode = "stable-privacy"; };
        wifi = { mode = "infrastructure"; ssid = "$HOME_SSID"; };
        wifi-security = { key-mgmt = "wpa-psk"; psk = "$HOME_PSK"; };
      };

      "nano-wifi" = {
        connection = {
          id = "nano-wifi";
          permissions = "";
          type = "wifi";
          autoconnect = true;
          interfaceName = "wlan0"; # adjust if needed
        };
        ipv4 = { method = "auto"; };
        ipv6 = { method = "auto"; addrGenMode = "stable-privacy"; };
        wifi = { mode = "infrastructure"; ssid = "$NANO_SSID"; };
        wifi-security = { key-mgmt = "wpa-psk"; psk = "$NANO_PSK"; };
      };
      
      "koshka-wifi" = {
        connection = {
          id = "koshka-wifi";
          permissions = "";
          type = "wifi";
          autoconnect = true;
          interfaceName= "wlan0";
        };
        ipv4 = { method = "auto"; };
        ipv6 = { method = "auto"; addrGenMode = "stable-privacy"; };
        wifi = { mode = "infrastructure"; ssid = "$KOSHKA_SSID"; };
        wifi-security = { key-mgmt = "wpa-psk"; psk = "$KOSHKA_PSK"; };
      };
    };
  };
}

