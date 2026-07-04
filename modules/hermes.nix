{ config, ... }:
{
  services.ollama = {
    enable = true;
    acceleration = false;
  };

  services.hermes-agent = {
    enable = true;
    stateDir = "${config.myServer.dataRoot}/hermes";
    config = {
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
    environmentFiles = [ config.sops.secrets."signal/allowed_users".path ];
    mcpServers.filesystem = {
      command = "npx";
    args = [ "-y" "@modelcontextprotocol/server-filesystem" "${config.myServer.dataRoot}/hermes-notes" ];
    };
  };

  systemd.services.hermes-agent.serviceConfig = {
    DynamicUser = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    NoNewPrivileges = true;
    ReadWritePaths = [ 
        "${config.myServer.dataRoot}/hermes"
        "${config.myServer.dataRoot}/hermes-notes"
     ];
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
    CapabilityBoundingSet = "";
  };

  gatewayPlatforms.signal = {
    phone = "+17203723131";
    daemon_url = "http://127.0.0.1:8087";
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
        ExecStart = "${pkgs.signal-cli}/bin/signal-cli -a +17203723131 daemon --http 127.0.0.1:8087";
        Restart = "always";
    };
  };
}