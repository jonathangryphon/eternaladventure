{ config, pkgs, lib, ... }:
{
  imports = [ ../hardware-configuration.nix ];

  networking.hostName = "Afabel";
  myServer.dataRoot = "/tank/services";
  myServer.zfsPoolReady = true;
}