{ config, pkgs, ... }:

# ssh keys are added/managed via ssh.nix

{
  users.mutableUsers = false; # users managed fully by nixos

  users.users.charity = {
    isNormalUser = true;
    description = "primary Admin user";
    extraGroups = [ "wheel" ]; # sudo access
  };

  users.users.breakglass = {
    isNormalUser = true;
    description = "break glass account for emergency remediation";
    extraGroups = [ "wheel" ]; # sudo access
  };
  
  users.users.syncoid = {
    description = "user for zfs backups";
    shell = pkgs.bash;
  };

  users.users.traefik.extraGroups = [ "podman" ];
}
