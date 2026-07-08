{ config, pkgs, ... }:

{
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      entryPoints.web.address = ":80";
      entryPoints.websecure.address = ":443";
      entryPoints.mc.address = ":33333";
    };
    dynamicConfigOptions.tcp = {
      routers = {
        https-passthrough = {
          entryPoints = [ "websecure" ];
          rule = "HostSNI(`*`)";
          service = "home-https";
          tls.passthrough = true;
        };
        http-passthrough = {
          entryPoints = [ "web" ];
          rule = "HostSNI(`*`)";
          service = "home-http";
        };
        mc-passthrough = {
          entryPoints = [ "mc" ];
          rule = "HostSNI(`*`)";
          service = "mc-home";
        };
      };
      services = {
        home-https.loadBalancer.servers = [{ address = "10.100.0.2:443"; }];
        home-http.loadBalancer.servers  = [{ address = "10.100.0.2:80"; }];
        mc-home.loadBalancer.servers    = [{ address = "10.100.0.2:33333"; }];
      };
    };
  };
}