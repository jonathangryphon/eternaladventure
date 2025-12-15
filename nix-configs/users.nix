{ config, pkgs, ... }:

# ssh keys are added/managed via ssh.nix

# users are completely managed by NixOS, so any password changes for example must be declared in the configs
users.mutableUsers = false;

{
  users.users.charity = {
    isNormalUser = true;
    description = "primary Admin user";
    extraGroups = [ "wheel" "podman" ]; # sudo + Podman access
    passwordLocked = true; # unnecessary. prevents console login. shows intent of config. 
  };

  users.users.breakglass = {
    isNormalUser = true;
    description = "break glass account for emergency remediation"
    extraGroups = [ "wheel" ];
    passwordLocked = true; # unnecessary. prevents console login. shows intent of config. 
  };

  users.groups.podman = { };
}
