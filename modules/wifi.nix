{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;

  networking.networkmanager.ensureProfiles.profiles = {
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
      wifi = { mode = "infrastructure"; ssid = "Zvezda Wifi"; };
      wifi-security = { keyMgmt = "wpa-psk"; pskFile = "/run/secrets/wifi/home-psk"; };
    };

    "sarah-wifi" = {
      connection = {
        id = "sarah-wifi";
        permissions = "";
        type = "wifi";
        autoconnect = true;
        interfaceName = "wlan0"; # adjust if needed
      };
      ipv4 = { method = "auto"; };
      ipv6 = { method = "auto"; addrGenMode = "stable-privacy"; };
      wifi = { mode = "infrastructure"; ssid = "Not Enough Cats"; };
      wifi-security = { keyMgmt = "wpa-psk"; pskFile = "/run/secrets/wifi/sarah-psk"; };
    };
  };
}

