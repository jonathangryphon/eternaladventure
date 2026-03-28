{ config, pkgs, lib, ... }:
 
{
  sops.secrets."porkbun/apikey" = {
    sopsFile = ./secrets/porkbun_secrets.yaml;
  };

  sops.secrets."porkbun/secretapikey" = {
    sopsFile = ./secrets/porkbun_secrets.yaml;
  };

  sops.secrets.home-wifi = {
    sopsFile = ./secrets/home-wifi.env.enc;
    format = "dotenv";
  };

  sops.secrets.nano-wifi = {
    sopsFile = ./secrets/nano-wifi.env.enc;
    format = "dotenv";
  };

  sops.secrets.koshka-wifi = {
    sopsFile = ./secrets/koshka-wifi.env.enc;
    format = "dotenv";
  };
  
  sops.secrets."nextcloud/admin_password" = {
    sopsFile = ./secrets/nextcloud_secrets.txt.enc;
    format = "binary";
  };
  
  sops.secrets."smtp/password" = {
    sopsFile = ./secrets/nextcloud_smtppassword.yaml;
  };
}
