{ config, pkgs, ... }:

# ssh keys are added/managed via ssh.nix

{
  # users are completely managed by NixOS, so any password changes for example must be declared in the configs
  # meaning that I can't add users by commands, if I do, anything I change is undone when nix rebuilds/updates
  users.mutableUsers = false;

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
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBKSEdTI/abCPT3mzcewZlssKY8IgBqr4bkIIA/tU2SD syncoid@Lulu"
    ];
  };
  users.users.traefik.extraGroups = [ "podman" ];
}
