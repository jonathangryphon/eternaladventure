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
}