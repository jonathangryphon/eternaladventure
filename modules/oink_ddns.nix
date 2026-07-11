{ config, lib, ... }:

let
  cfg = config.myDomain;
in
{
  options.myDomain = {
    domain = lib.mkOption {
      type = lib.types.str;
      default = "eternaladventure.xyz";
      description = "The base domain to update.";
    };

    records = lib.mkOption {
      description = "DNS records managed by oink.";

      type = lib.types.listOf (lib.types.submodule ({ ... }: {
        options = {
          subdomain = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "The subdomain.";
          };

          ttl = lib.mkOption {
            type = lib.types.int;
            default = 600;
            description = "DNS TTL.";
          };
        };
      }));

      default = [
        { subdomain = ""; }
        { subdomain = "*"; }
      ];
    };
  };

  config = {
    services.oink = {
      # enable = true;

      apiKeyFile = "/run/secrets/porkbun/apikey";
      secretApiKeyFile = "/run/secrets/porkbun/secretapikey";

      settings = {
        interval = 900;
        ttl = 600;
      };

      domains = map (record:
        record // {
          domain = cfg.domain;
        }
      ) cfg.records;
    };

    sops.secrets."porkbun/apikey".sopsFile =
      ../secrets/porkbun_secrets.yaml;

    sops.secrets."porkbun/secretapikey".sopsFile =
      ../secrets/porkbun_secrets.yaml;
  };
}