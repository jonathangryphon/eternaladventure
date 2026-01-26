{ config, pkgs, ... }:
{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    https = false;
    hostName = "nextcloud.eternaladventure.xyz";
    maxUploadSize = "50G";
    config = {
      adminpassFile = config.sops.secrets."nextcloud/admin_password".path;
      dbtype = "sqlite";
    };
    settings = {
      overwriteprotocol = "https";
      trusted_proxies = [ "127.0.0.1" ];
      mail_from_address = "noreply";
      mail_smtphost = "smtp.gmail.com";
      mail_smtpport = 465;
      mail_smtpsecure = "ssl";
      mail_smtpauth = true;
      mail_smtpname = "eternaladventure.recovery@gmail.com";
    };
    home = "/tank/services/nextcloud";
    
    secrets.mail_smtppassword = "/run/secrets/smtp_password";
    
  };
  
  # Nginx default port change so that internally nextcloud is exposed at 8080
  # Traefik then picks it up and routes traffic accordingly
  services.nginx.virtualHosts."${config.services.nextcloud.hostName}".listen = [
    { addr = "127.0.0.1";
      port = 8080; }
   ];

  services.nginx.clientMaxBodySize = "50G";
 
  # Traefik Required Bits
  services.traefik.dynamicConfigOptions.http.routers.nextcloud = {
    rule = "Host(`nextcloud.eternaladventure.xyz`)";
    entryPoints = [ "websecure" ];
    service = "nextcloud-service";
    tls.certResolver = "letsencrypt";
  };

  services.traefik.dynamicConfigOptions.http.services.nextcloud-service = {
    loadBalancer.servers = [
      { url = "http://127.0.0.1:8080"; }
    ];
  };
}
