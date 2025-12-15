{ config, pkgs, ... }:

{
  users.users.charity = {
    isNormalUser = true;
    description = "main Admin user";
    extraGroups = [ "wheel" "podman" ]; # sudo + Podman access
  };

  users.groups.podman = { };
}
