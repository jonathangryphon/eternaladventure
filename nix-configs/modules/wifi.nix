{ config, pkgs, lib, ... }:

let
  wifiNetworks = [
    { name = "home-wifi";   ssid = "Zvezda Wifi";       pskFile = "/run/secrets/wifi/home-wifi-psk"; }
    { name = "sarah-wifi"; ssid = "";  pskFile = "/run/secrets/wifi/sarah-wifi-psk"; }
  ];
in {
  networking.networkmanager.enable = true;

  networking.networkmanager.ensureProfiles = lib.listToAttrs (map (network: {
    name = network.name;
    value = {
      connection = {
        id = network.name;
        type = "wifi";
        interface-name = "wlan0"; # adjust to your interface
        autoconnect = true;
      };
      wifi = {
        ssid = network.ssid;
        mode = "infrastructure";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk-file = network.pskFile;
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    };
  ) wifiNetworks);
}

