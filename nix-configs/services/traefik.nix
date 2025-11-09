{ config, pkgs, ... }:

{
  services.traefik.enable = true;
  services.traefik.acme.email = "your-email@example.xyz";
  services.traefik.entryPoints = [ "web" "websecure" ];
}