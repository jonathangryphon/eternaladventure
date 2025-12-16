{ config, pkgs, ... }:

{
  services.openssh = {
      enable = true;
      settings = {
        Port  = [ 65555 ]; # security through obscurity to avoid default port scanning of 22
        PasswordAuthentication = false;
        PubkeyAuthentication = true; # unnecessary I think, but declares intent
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "charity" "breakglass" ];
      };
    };

  # Associate SSH keys with users
  users.users.charity.openssh.authorizedKeys.keys = [
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHawf4YO7tfG/BkWfw0E+aQRThKTIsGjXSwDBfQK/VGF charity@macbook
  ];

  users.users.breakglass.openssh.authorizedKeys.keys = [
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFGPtcNoxFq+KnnCvt5xmBAOfzLXWul3i0MmOA8W/FXl breakglass@macbook
  ];  
}
