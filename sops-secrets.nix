{ config, pkgs, lib, ... }:
 
{
  sops.secrets."porkbun/apikey" = {
    sopsFile = ./secrets/porkbun_secrets.yaml;
    key = "porkbun.apikey";
  };

  sops.secrets."porkbun/secretapikey" = {
    sopsFile = ./secrets/porkbun_secrets.yaml;
    key = "porkbun.secretapikey";
  };

  sops.secrets."wifi/home-psk" = { 
    sopsFile = ./secrets/wifi_secrets.yaml;
    key = "wifi.home-wifi.psk";
  };
  
  sops.secrets."wifi/sarah-psk" = { 
    sopsFile = ./secrets/wifi_secrets.yaml;
    key = "wifi.sarah-wifi.psk";
  };
}
