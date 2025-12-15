{ config, pkgs, ... }:

# ssh keys are added/managed via ssh.nix

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
