{ config, pkgs, ... }:

{
  services.openssh = {
      enable = true;
      settings = {
        Port  = [ 62022 ]; # security through obscurity to avoid default port scanning of 22
        PasswordAuthentication = false;
        PubkeyAuthentication = true; # this is the default, but declaring it expresses code intent
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "charity" "breakglass" ];
      };
    };
  
  networking.firewall.allowedTCOPorts = [ 62022 ]; # open port for ssh
  
  # Associate SSH keys with users
  users.users.charity.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHawf4YO7tfG/BkWfw0E+aQRThKTIsGjXSwDBfQK/VGF charity@macbook"
  ];

  users.users.breakglass.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFGPtcNoxFq+KnnCvt5xmBAOfzLXWul3i0MmOA8W/FXl breakglass@macbook"
  ];  
}
