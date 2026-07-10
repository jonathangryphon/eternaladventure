{ config, lib, pkgs, ... }:
let 
  cfg = config.mySsh;
in
{
  options = {
    mySsh.port = lib.mkOption {
      type = lib.types.int;
      default = 62022;
      description = "SSH port for this host.";
    };
  };
  
  config = {
    services.openssh = {
      enable = true;
      ports = [ cfg.port ]; # security through obscurity to avoid default port 22 scanning via bots

      settings = {
        PasswordAuthentication = false;
        PubkeyAuthentication = true; # this is the default, but declaring it expresses code intent
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "charity" "breakglass" ];
      };
    };
  
    networking.firewall.allowedTCPPorts = [ cfg.port ]; # open port for ssh
  };
}
