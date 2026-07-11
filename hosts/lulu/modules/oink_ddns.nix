{ config, pkgs, lib, ... }:
let
  cfg = config.myDomain;
in
{
  options = {
    myDomain.subdomain = lib.mkOption {
      type = lib.types.str;
      default = "example";
      description = "Subdomain to add to DNS dynamically.";
    };
  };
  
  config = {
    services.oink = {
      enable = true;
      apiKeyFile = "/run/secrets/porkbun/apikey";
      secretApiKeyFile = "/run/secrets/porkbun/secretapikey";
      settings.interval = 900; # seconds between updates
      settings.ttl = 600;      # DNS TTL
      domains = [
        { domain = "eternaladventure.xyz"; subdomain = cfg.subdomain; ttl = 600; }
      ];
    };
  
    sops.secrets."porkbun/apikey" = {
      sopsFile = ../../../secrets/porkbun_secrets.yaml;
    };

    sops.secrets."porkbun/secretapikey" = {
      sopsFile = ../../../secrets/porkbun_secrets.yaml;
    };
  };
}
