{ config, pkgs, ... }:

{
  services.openssh = {
      enable = true;
      ports = [ 62022 ]; # security through obscurity to avoid default port 22 scanning via bots

      settings = {
        PasswordAuthentication = false;
        PubkeyAuthentication = true; # this is the default, but declaring it expresses code intent
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "charity" "breakglass" "syncoid" ];
      };
    };
  
  networking.firewall.allowedTCPPorts = [ 62022 ]; # open port for ssh
}
