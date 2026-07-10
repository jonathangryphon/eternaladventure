{ ... }:
{
    services.headscale = {
        enable = true;
        settings = {
            server_url = "https://headscale.eternaladventure.xyz";
            dns.magic_dns = true;
            dns.base_domain = "ts.eternaladventure.xyz";
            dns.nameservers.global = [ "9.9.9.9" "149.112.112.112" ];
        };
    };
    # Traefik Required Bits
    services.traefik.dynamicConfigOptions.http.routers.headscale = {
        rule = "Host(`headscale.eternaladventure.xyz`)";
        entryPoints = [ "websecure" ];
        service = "headscale-service";
        tls.certResolver = "letsencrypt";
    };

    services.traefik.dynamicConfigOptions.http.services.headscale-service = {
        loadBalancer.servers = [
            { url = "http://127.0.0.1:8080"; }
        ];
    };
}