{ config, pkgs, lib, ... }:
{
  networking.hostName = "Afabel";
  myServer.dataRoot = "/tank/services";
  myServer.zfsPoolReady = true;
}