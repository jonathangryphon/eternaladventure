{ config, pkgs, ... }:

{
  systemd.services.ente = {
    description = "Ente Photos Container";
    after = [ "network.target" ];
    wants = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.podman}/bin/podman run --rm -p 8080:80 entefm/ente:latest";
      Restart = "always";
      User = "admin"; # rootless
    };
    wantedBy = [ "multi-user.target" ];
  };
}