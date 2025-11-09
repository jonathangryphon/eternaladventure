{ config, pkgs, ... }:

{
  users.users.charity = {
    isNormalUser = true;
    extraGroups = [ "wheel" "podman" ]; # sudo + Podman access
  };

  users.groups.podman = { };
}