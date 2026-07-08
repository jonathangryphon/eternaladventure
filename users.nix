{ config, pkgs, ... }:

# ssh keys are added/managed via ssh.nix

{
  users.mutableUsers = false; # users managed fully by nixos

  users.users.charity = {
    isNormalUser = true;
    description = "primary Admin user";
    extraGroups = [ "wheel" ]; # sudo access
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHawf4YO7tfG/BkWfw0E+aQRThKTIsGjXSwDBfQK/VGF charity@macbook"
    ];
  };

  users.users.breakglass = {
    isNormalUser = true;
    description = "break glass account for emergency remediation";
    extraGroups = [ "wheel" ]; # sudo access
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFGPtcNoxFq+KnnCvt5xmBAOfzLXWul3i0MmOA8W/FXl breakglass@macbook"
    ];    
  };
}
