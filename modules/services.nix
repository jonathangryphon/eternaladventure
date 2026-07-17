{config, pkgs, lib, sops-nix, ... }:
{
    imports = [
        ../../modules/services/nextcloud.nix
        ../../modules/services/jellyfin.nix
        ../../modules/services/ente.nix
        ../../modules/services/traefik-dashboard.nix
        ../../modules/services/minecraft-server.nix
        ../../modules/services/headscale-server.nix 
    ];
}