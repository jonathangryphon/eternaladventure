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
}
