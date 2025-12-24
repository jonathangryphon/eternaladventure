{ config, pkgs, lib, ... }:
{
  services.oink = {
    enable = true;
    apiKeyFile = "/run/secrets/porkbun/apikey";
    secretApiKeyFile = "/run/secrets/porkbun/secretapikey";
    settings.interval = 900; # seconds between updates
    settings.ttl = 600;      # DNS TTL
    domains = [
      { domain = "eternaladventure.xyz"; subdomain = ""; ttl = 600; }
    ];
  };
}
