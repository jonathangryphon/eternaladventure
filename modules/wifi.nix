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
    systemd.services.nm-wifi-profiles = {
    description = "Recreate NetworkManager WiFi profiles from sops secrets";
    after = [ "sops-nix.service" "NetworkManager.service" "network.target" ];
    requires = [ "sops-nix.service" "NetworkManager.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      EnvironmentFile = [
        config.sops.secrets.home-wifi.path
        config.sops.secrets.nano-wifi.path
        config.sops.secrets.koshka-wifi.path
      ];
    };
    script = ''
      upsert() {
        local name=$1
        local ssid=$2
        local psk=$3
        nmcli connection show "$name" &>/dev/null && \
          nmcli connection delete "$name"
        nmcli connection add \
          type wifi \
          con-name "$name" \
          ssid "$ssid" \
          wifi-sec.key-mgmt wpa-psk \
          wifi-sec.psk "$psk" \
          connection.autoconnect yes \
          connection.permissions "" \
          ifname wlan0
      }

      upsert "home-wifi"   "$HOME_SSID"   "$HOME_PSK"
      upsert "nano-wifi"   "$NANO_SSID"   "$NANO_PSK"
      upsert "koshka-wifi" "$KOSHKA_SSID" "$KOSHKA_PSK"
    '';
  };
}

