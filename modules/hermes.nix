{ config, pkgs, lib, ... }:
{
  services.ollama = {
    enable = true;
    acceleration = false;
  };

  services.hermes-agent = {
    enable = true;
    stateDir = "${config.myServer.dataRoot}/hermes";
    settings = {
      model = {
        default = "qwen2.5:14b-instruct-q4_K_M";
        provider = "openai-compatible";
        base_url = "http://localhost:11434/v1";
      };
      terminal = {
        backend = "local";
        timeout = 18000;
        lifetime_seconds = 18000;
      };
      agent = {
        max_turns = 200;
        reasoning_effort = "high";
      };
      memory = {
        memory_enabled = true;
        user_profile_enabled = true;
      };
      toolsets = [ "filesystem" "memory" ];
    };
    environment = {
      SIGNAL_ACCOUNT = "+17203723131";
      SIGNAL_HTTP_URL = "http://127.0.0.1:8087";
    };
    environmentFiles = [ config.sops.secrets."signal/allowed_users".path ];
    mcpServers.filesystem = {
      command = "npx";
      args = [ "-y" "@modelcontextprotocol/server-filesystem" "${config.myServer.dataRoot}/hermes-notes" ];
    };
  };

  systemd.services.hermes-agent.serviceConfig = {
    DynamicUser = true;
    ProtectSystem = "strict";
    ProtectHome = lib.mkForce true;
    PrivateTmp = true;
    NoNewPrivileges = true;
    ReadWritePaths = [ 
        "${config.myServer.dataRoot}/hermes"
        "${config.myServer.dataRoot}/hermes-notes"
     ];
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
    CapabilityBoundingSet = "";
  };

  users.users.signal-cli = {
    isSystemUser = true;
    group = "signal-cli";
    home = "${config.myServer.dataRoot}/signal-cli";
    createHome = true;
  };

  users.groups.signal-cli = {};

  systemd.services.signal-cli-daemon = {
    description = "signal-cli HTTP daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
        User = "signal-cli";
        Environment = "XDG_DATA_HOME=${config.myServer.dataRoot}/signal-cli";
        ExecStart = "${pkgs.unstable.signal-cli}/bin/signal-cli -a +17203723131 daemon --http 127.0.0.1:8087";
        Restart = "always";
    };
  };
}