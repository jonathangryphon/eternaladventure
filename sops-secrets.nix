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
  sops.secrets."ente/key_encryption" = {
    sopsFile = ./secrets/ente_secrets.yaml;
    owner = "ente";
  };
  sops.secrets."ente/key_hash" = {
    sopsFile = ./secrets/ente_secrets.yaml;
    owner = "ente";
  };
  sops.secrets."ente/jwt_secret" = {
    sopsFile = ./secrets/ente_secrets.yaml;
    owner = "ente";
  };
  sops.secrets."ente/garage_access_key_id" = {
    sopsFile = ./secrets/ente_secrets.yaml;
    owner = "ente";
  };
  sops.secrets."ente/garage_secret_access_key" = {
    sopsFile = ./secrets/ente_secrets.yaml;
    owner = "ente";
  };
  sops.secrets."ente/garage_rpc_key" = {
    sopsFile = ./secrets/ente_secrets.yaml;
    owner = "ente";
  };
  sops.secrets."smtp/password" = {
    sopsFile = ./secrets/ente_smtp.yaml;
  };
  sops.secrets."smtp/username" = {
    sopsFile = ./secrets/ente_smtp.yaml;
  };
}
