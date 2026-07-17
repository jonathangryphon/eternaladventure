{config, pkgs, lib, sops-nix, ... }:
{
    imports = [
        ./services/nextcloud.nix
        ./services/jellyfin.nix
        ./services/ente.nix
        ./services/traefik-dashboard.nix
        ./services/minecraft-server.nix
        ./services/headscale-server.nix 
    ];
}