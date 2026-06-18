{ config, pkgs, lib, ... }:
{
  imports = [ ./hardware-rosalina.nix ];

  networking.hostName = "Afabel";
  myServer.dataRoot = "/tank/services";
  myServer.zfsPoolReady = true;
}