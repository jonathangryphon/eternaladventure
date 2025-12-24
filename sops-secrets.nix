{ config, pkgs, lib, ... }:
 
{
  sops.secrets."porkbun/apikey" = {
    sopsFile = ./secrets/porkbun_secrets.yaml;
  };

  sops.secrets."porkbun/secretapikey" = {
    sopsFile = ./secrets/porkbun_secrets.yaml;
  };

  sops.secrets."wifi/home-psk" = { 
    sopsFile = ./secrets/wifi_secrets.yaml;
  };
  
  sops.secrets."wifi/sarah-psk" = { 
    sopsFile = ./secrets/wifi_secrets.yaml;
    # key = "wifi.sarah-wifi.psk"; # this key entry on each thing was erroring out because, essentially, sops was trying to eval the key twice. Once with the top line [sops.secrets."" =] and once with the key = bit. so it's entirely unnecessary
  };
}
