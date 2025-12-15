{ config, pkgs, ... }:

{
  users.users.charity = {
    isNormalUser = true;
    description = "primary Admin user";
    extraGroups = [ "wheel" "podman" ]; # sudo + Podman access
  };

  users.users.breakglass = {
    isNormalUser = true;
    description = "break glass account for emergency remediation"
    extraGroups = [ "wheel" ];
    passwordLocked = true; # prevents console login
  };

  users.groups.podman = { };
}
