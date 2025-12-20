{ config, pkgs, lib, ... }:

let
  # ----------------------------
  # Domain & DDNS config
  # ----------------------------
  domain = "eternaladventure.xyz”;       # Master domain (A record)
  ttl = 600;                    # Record TTL in seconds

  # Secrets paths (never committed to git)
  apiKeyPath = "/etc/secrets/porkbun-apikey";
  secretKeyPath = "/etc/secrets/porkbun-secretkey";

  # File to store last known IP
  stateFile = "/var/lib/ddns/current-ip.txt";
in
{
  ############################
  # DDNS Script
  ############################
  environment.etc."scripts/update-porkbun-ip.sh".text = lib.concatStringsSep "\n" [
    "#!/usr/bin/env bash"
    "set -euo pipefail"
    ""
    "# ----------------------------"
    "# Config"
    "# ----------------------------"
    "DOMAIN=${domain}"
    "TTL=${toString ttl}"
    "STATE_FILE=${stateFile}"
    ""
    "# Get current public IP"
    "IP=$(curl -s https://ifconfig.me)"
    "echo \"Current public IP: $IP\""
    ""
    "# Check if IP changed"
    "if [ -f \"$STATE_FILE\" ] && [ \"$(<\"$STATE_FILE\")\" = \"$IP\" ]; then"
    "  echo \"IP unchanged, skipping update.\""
    "  exit 0"
    "fi"
    ""
    "# Read API keys"
    "API_KEY=$(<\"${apiKeyPath}\")"
    "SECRET_KEY=$(<\"${secretKeyPath}\")"
    ""
    "# Update master A record"
    "RESPONSE=$(curl -s -X POST \"https://api.porkbun.com/api/json/v3/dns/editByNameType/$DOMAIN/A/@\" \\"
    "  -H \"Content-Type: application/json\" \\"
    "  -d '{\"apikey\":\"'$API_KEY'\",\"secretapikey\":\"'$SECRET_KEY'\",\"content\":\"'$IP'\",\"ttl\":\"'$TTL'\"}')"
    "STATUS=$(echo \"$RESPONSE\" | jq -r '.status')"
    "if [ \"$STATUS\" != \"SUCCESS\" ]; then"
    "  echo \"Master A record update failed: $RESPONSE\""
    "  exit 1"
    "fi"
    "echo \"Master A record updated successfully.\""
    ""
    "# Save current IP for next check"
    "mkdir -p $(dirname \"$STATE_FILE\")"
    "echo \"$IP\" > \"$STATE_FILE\""
  ];

  environment.etc."scripts/update-porkbun-ip.sh".mode = "0755";

  ############################
  # Systemd Service
  ############################
  systemd.services.updatePorkbunIP = {
    description = "Update Porkbun master A record for dynamic IP";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/etc/scripts/update-porkbun-ip.sh";
    };
  };

  ############################
  # Systemd Timer
  ############################
  systemd.timers.updatePorkbunIP = {
    description = "Run updatePorkbunIP every 10 minutes";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "10min";
      Persistent = true;
    };
  };
}


