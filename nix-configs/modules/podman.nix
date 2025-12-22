{ config, pkgs, lib, ... }:

{
  # Podman Group Init
  users.groups.podman = {};

  # Podman service
  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
    autoPrune.enable = true;
  };
  
  systemd.sockets.podman = {
    wantedBy [ "sockets.target" ];
    socketConfig = {
      ListenStream = "/run/podman/podman.sock";
      SocketMode = "06600";
      SocketUser = "root";
      SocketGroup = "podman";
    };
  };
  
  # Docker compatibility not needed unless using docker direct YAML configs and such
  # services.podman.dockerCompat = false;
}

