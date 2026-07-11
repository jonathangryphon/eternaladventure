{ config, pkgs, ... }:

{
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      entryPoints.web.address = ":80";
      entryPoints.websecure.address = ":443";
      entryPoints.mc.address = ":33333";
      entryPoints.ssh-afabel.address = ":62022";      
      entryPoints.ssh-lulu.address = ":62023";
    };
    dynamicConfigOptions.http = {
      routers.http-home = {
        rule = "PathPrefix(`/`)";
        entryPoints = [ "web" ];
        service = "home-http";
      };
    };
    dynamicConfigOptions.tcp = {
      routers = {
        https-passthrough = {
          entryPoints = [ "websecure" ];
          rule = "HostSNI(`*`)";
          service = "home-https";
          tls.passthrough = true;
        };
        mc-passthrough = {
          entryPoints = [ "mc" ];
          rule = "HostSNI(`*`)";
          service = "mc-home";
        };
        ssh-afabel-passthrough = {
          entryPoints = [ "ssh-afabel" ];
          rule = "HostSNI(`*`)";
          service = "ssh-afabel-home";
        };
        ssh-lulu-passthrough = {
          entryPoints = [ "ssh-lulu" ];
          rule = "HostSNI(`*`)";
          service = "ssh-lulu-home";
        };
      };
      services = {
        home-https.loadBalancer.servers = [{ address = "10.100.0.2:443"; }];
        home-http.loadBalancer.servers  = [{ address = "10.100.0.2:80"; }];
        mc-home.loadBalancer.servers    = [{ address = "10.100.0.2:33333"; }];
        ssh-afabel-home.loadBalancer.servers = [{ address = "10.100.0.2:62022"; }];
        ssh-lulu-home.loadBalancer.servers = [{ address = "10.100.0.3:62023"; }];
      };
    };
  };
}