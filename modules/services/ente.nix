# ente.nix — Self-hosted Ente Photos on NixOS
# Stack: Garage (S3) + Ente API (museum) + Ente web frontend + Traefik
#
# Import from your configuration.nix:
#   imports = [ ./ente.nix ];
#
# Before first rebuild:
#   1. Generate secrets and write them to files:
#        sudo mkdir -p /etc/ente
#        echo -n "$(openssl rand -base64 32)" | sudo tee /etc/ente/key-encryption
#        echo -n "$(openssl rand -base64 64)" | sudo tee /etc/ente/key-hash
#        echo -n "$(openssl rand -base64 32)" | sudo tee /etc/ente/jwt-secret
#        sudo chmod 600 /etc/ente/*
#
#   2. Fill in your email in hardcoded-ott below.
#
#   After first rebuild, do the Garage bootstrap (see bottom of file),
#   then fill in the garage key/secret _secret paths.

{ config, pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # 1. GARAGE — S3-compatible object storage
  # ---------------------------------------------------------------------------
  services.garage = {
    enable = true;
    package = pkgs.garage;

    settings = {
      metadata_dir = "/var/lib/garage/meta";
      data_dir     = "/tank/services/garage/data";

      replication_factor = 1;

      s3_api = {
        s3_region     = "garage";
        api_bind_addr = "127.0.0.1:3900";
      };

      admin = {
        api_bind_addr = "127.0.0.1:3903";
      };
      
      rpc_bind_addr = "127.0.0.1:3901";
      rpc_public_addr = "127.0.0.1:3901";
    };
  };

  # ---------------------------------------------------------------------------
  # 2. ENTE API (museum) — binds to 127.0.0.1:8080 by default
  # ---------------------------------------------------------------------------
  services.ente.api = {
    enable        = true;
    enableLocalDB = true;   # manages PostgreSQL automatically
    nginx.enable  = false;  # Traefik handles routing, not nginx

    domain = "api.eternaladventure.xyz";

    settings = {
      s3 = {
        are_local_buckets   = true;
        use_path_style_urls = true;

        # "b2-eu-cen" is a required fixed key name in museum.
        # The actual backend can be any S3-compatible store.
        "b2-eu-cen" = {
          endpoint = "http://127.0.0.1:3900";
          region   = "garage";
          bucket   = "ente";
          # Populate these files after Garage bootstrap (see bottom of file)
          key._secret    = config.sops.secrets."ente/garage_access_key_id".path;
          secret._secret = config.sops.secrets."ente/garage_secret_access_key".path;
        };
      };

      key = {
        encryption._secret = config.sops.secrets."ente/key_encryption".path;
        hash._secret       = config.sops.secrets."ente/key_hash".path;
      };

      jwt.secret._secret = config.sops.secrets."ente/jwt_secret".path;

      internal = {
        # Lets you log in with OTP 123456 — no SMTP needed for first setup.
        # Change this to your actual email address.
        hardcoded-ott.emails = [ "YOUR_EMAIL@example.com,123456" ];

        # Flip to true after you've created your account.
        disable-registration = false;
      };
    };
  };

  # ---------------------------------------------------------------------------
  # 3. ENTE WEB FRONTEND
  # ---------------------------------------------------------------------------
  # The module creates nginx virtualHosts for each subdomain.
  # We override them to listen on localhost ports (same pattern as Nextcloud)
  # so Traefik can proxy them and handle TLS.
  services.ente.web = {
    enable = true;
    domains = {
      # .api is auto-set from services.ente.api.domain when both are enabled
      accounts = "accounts.eternaladventure.xyz";
      albums   = "albums.eternaladventure.xyz";
      cast     = "cast.eternaladventure.xyz";
      photos   = "photos.eternaladventure.xyz";
    };
  };

  # Override the nginx virtual hosts created by services.ente.web.
  # Force each to listen on localhost only, no SSL (Traefik terminates TLS).
  # albums shares the photos virtualHost via serverAliases in the module,
  # so we only need to override three hosts.
  services.nginx.virtualHosts = {
    "accounts.eternaladventure.xyz" = {
      forceSSL = false;
      listen   = [{ addr = "127.0.0.1"; port = 8081; }];
    };
    "cast.eternaladventure.xyz" = {
      forceSSL = false;
      listen   = [{ addr = "127.0.0.1"; port = 8082; }];
    };
    "photos.eternaladventure.xyz" = {
      forceSSL = false;
      # albums.eternaladventure.xyz is a serverAlias here, so this port
      # serves both photos and albums.
      listen   = [{ addr = "127.0.0.1"; port = 8083; }];
    };
  };

  # ---------------------------------------------------------------------------
  # 4. TRAEFIK routers + services
  # ---------------------------------------------------------------------------
  services.traefik.dynamicConfigOptions.http = {
    routers = {
      ente-api = {
        rule        = "Host(`api.eternaladventure.xyz`)";
        entryPoints = [ "websecure" ];
        service     = "ente-api-service";
        tls.certResolver = "letsencrypt";
      };
      ente-photos = {
        rule        = "Host(`photos.eternaladventure.xyz`)";
        entryPoints = [ "websecure" ];
        service     = "ente-photos-service";
        tls.certResolver = "letsencrypt";
      };
      ente-albums = {
        rule        = "Host(`albums.eternaladventure.xyz`)";
        entryPoints = [ "websecure" ];
        service     = "ente-photos-service"; # same backend as photos
        tls.certResolver = "letsencrypt";
      };
      ente-accounts = {
        rule        = "Host(`accounts.eternaladventure.xyz`)";
        entryPoints = [ "websecure" ];
        service     = "ente-accounts-service";
        tls.certResolver = "letsencrypt";
      };
      ente-cast = {
        rule        = "Host(`cast.eternaladventure.xyz`)";
        entryPoints = [ "websecure" ];
        service     = "ente-cast-service";
        tls.certResolver = "letsencrypt";
      };
    };

    services = {
      ente-api-service.loadBalancer.servers      = [{ url = "http://127.0.0.1:8080"; }];
      ente-photos-service.loadBalancer.servers   = [{ url = "http://127.0.0.1:8083"; }];
      ente-accounts-service.loadBalancer.servers = [{ url = "http://127.0.0.1:8081"; }];
      ente-cast-service.loadBalancer.servers     = [{ url = "http://127.0.0.1:8082"; }];
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}

# =============================================================================
# AFTER DEPLOYING — one-time Garage bootstrap
# =============================================================================
# Run these after nixos-rebuild switch, before starting ente:
#
# 1.  garage status
#     → note your node ID
#
# 2.  garage layout assign -z dc1 -c 100G <node-id>
#     garage layout apply --version 1
#
# 3.  garage bucket create ente
#
# 4.  garage key create ente-key
#     → prints an access key ID and secret. Write them:
#       echo -n "THE_KEY_ID"     | sudo tee /etc/ente/garage-access-key-id
#       echo -n "THE_KEY_SECRET" | sudo tee /etc/ente/garage-secret-access-key
#       sudo chmod 600 /etc/ente/garage-access-key-id /etc/ente/garage-secret-access-key
#
# 5.  garage bucket allow --read --write --owner ente --key ente-key
#
# 6.  sudo systemctl restart ente
#
# 7.  Open https://photos.eternaladventure.xyz
#     Log in with your email — OTP is 123456.
#     After creating your account, set disable-registration = true and rebuild.
