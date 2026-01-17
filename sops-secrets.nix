{ config, pkgs, lib, ... }:
 
{
  sops.secrets."porkbun/apikey" = {
    sopsFile = ./secrets/porkbun_secrets.yaml;
  };

  sops.secrets."porkbun/secretapikey" = {
    sopsFile = ./secrets/porkbun_secrets.yaml;
  };

  sops.secrets."wifi/home-wifi/psk" = { 
    sopsFile = ./secrets/wifi_secrets.yaml;
  };
  
  sops.secrets."wifi/sarah-wifi/psk" = { 
    sopsFile = ./secrets/wifi_secrets.yaml;
    # key = "wifi.sarah-wifi.psk"; # this key entry on each thing was erroring out because, essentially, sops was trying to eval the key twice. Once with the top line [sops.secrets."" =] and once with the key = bit. so it's entirely unnecessary
  };
  
  sops.secrets."wifi/koshka-wifi/psk" = {
    sopsFile = ./secrets/wifi_secrets.yaml;
  };
  sops.secrets."nextcloud/admin_password" = {
    sopsFile = ./secrets/nextcloud_secrets.yaml;
  };
}
