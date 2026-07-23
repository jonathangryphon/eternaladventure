# modules/mail.nix
{ config, pkgs, lib, ... }:
let
  domain = "eternaladventure.xyz";
  # reuse the cert Traefik/lego already produces via DNS-01 — no second ACME client needed
  certDir = "/var/lib/acme/${domain}";
  dataDir = config.myServer.dataRoot + "/stalwart";
in
{
  # in afabel's host config
  sops.secrets."mailjet-api-key" = {
    sopsFile = ../secrets/mailjet-smtp.yaml;
    owner = "stalwart";
  };
  sops.secrets."mailjet-secret-key" = {
    sopsFile = ../secrets/mailjet-smtp.yaml;
    owner = "stalwart";
  };
  sops.secrets."admin-secret" = { sopsFile = ../secrets/stalwart.yaml; owner = "stalwart"; };
  sops.secrets."example-mailbox-secret" = { sopsFile = ../secrets/stalwart.yaml; owner = "stalwart"; };

  services.stalwart = {
    enable = true;
    stateVersion = "26.05";
    credentials = {
      mailjet-user = config.sops.secrets."mailjet-api-key".path;
      mailjet-pass = config.sops.secrets."mailjet-secret-key".path;
      admin-secret = config.sops.secrets."admin-secret".path;
    };

    settings = {
      server.hostname = "mail.${domain}";

      certificate."main" = {
        cert = "%{file:${certDir}/fullchain.pem}%";
        private-key = "%{file:${certDir}/key.pem}%";
      };
      server.tls = { certificate = "main"; enable = true; };

      server.listener = {
        admin = { bind = [ "127.0.0.1:8095" ]; protocol = "http"; };
        smtp = { bind = [ "[::]:25" ]; protocol = "smtp"; };
        submission = { bind = [ "[::]:587" ]; protocol = "smtp"; };
        submissions = { bind = [ "[::]:465" ]; protocol = "smtp"; tls.implicit = true; };
        imaps = { bind = [ "[::]:993" ]; protocol = "imap"; tls.implicit = true; };
      };

      authentication.fallback-admin = {
        user = "admin";
        secret = "%{file:/run/credentials/stalwart.service/admin-secret}%";
      };

      storage.data = "mail-store";
      storage.blob = "mail-store";
      storage.fts = "mail-store";
      storage.lookup = "mail-store";
      store.mail-store = { type = "rocksdb"; path = "${dataDir}/database"; };

      # decide, per-recipient, which named route to use
      queue.strategy.route = [
        { if = "is_local_domain('*', rcpt_domain)"; then = "'local'"; }
        { else = "'mailjet'"; }
      ];

      # local delivery — no extra params, just declares the name the expression above references
      queue.route."local" = { type = "local"; };

      # the actual relay route, replacing the old `relay."mailjet"` + `next-hop` pair
      queue.route."mailjet" = {
        type = "relay";
        address = "in-v3.mailjet.com";
        port = 587;
        protocol = "smtp";
        tls.implicit = false;
        auth = {
          username = "%{file:/run/credentials/stalwart.service/mailjet-user}%";
          secret   = "%{file:/run/credentials/stalwart.service/mailjet-pass}%";
        };
      };
  };
  # let stalwart read the ACME-produced cert files
  users.users.stalwart.extraGroups = [ "acme" ];

  # the dynamic layer: domain + mailbox upserts, applied idempotently on every activation
  environment.etc."stalwart/plan.ndjson".text = lib.concatMapStringsSep "\n" builtins.toJSON [
    { op = "upsert"; type = "domain"; name = domain; }
    {
      op = "upsert"; type = "principal"; name = "example";
      email = [ "example@${domain}" ];
      secret = "%{file:/run/credentials/stalwart-apply.service/mailbox-secret}%";
    }
  ];

  systemd.services.stalwart-apply = {
    description = "Apply Stalwart declarative account/domain plan";
    after = [ "stalwart.service" ];
    requires = [ "stalwart.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      LoadCredential = "mailbox-secret:${config.sops.secrets."stalwart-mailbox-secret".path}";
      ExecStart = "${pkgs.stalwart}/bin/stalwart-cli --url https://localhost:8095 --credentials admin:%{file:/run/credentials/stalwart.service/admin-secret}% apply /etc/stalwart/plan.ndjson";
    };
  };

  # mark packets from the stalwart user
  networking.nftables.ruleset = ''
    table inet mangle {
      chain output {
        type filter hook output priority -150;
        meta skuid stalwart mark set 0x1
      }
    }
  '';

  # send marked packets out a separate table that defaults via the tunnel
  systemd.services.stalwart-egress-route = {
    wantedBy = [ "multi-user.target" ];
    after = [ "wireguard-wg0.service" ];
    bindsTo = [ "wireguard-wg0.service" ]; # go down with the tunnel, don't silently blackhole
    script = ''
      ${pkgs.iproute2}/bin/ip rule add fwmark 0x1 table 100 || true
      ${pkgs.iproute2}/bin/ip route add default dev wg0 table 100 || true
    '';
    preStop = ''
      ${pkgs.iproute2}/bin/ip rule del fwmark 0x1 table 100 || true
      ${pkgs.iproute2}/bin/ip route del default dev wg0 table 100 || true
    '';
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
  };
}