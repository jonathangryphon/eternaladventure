{ ... }:
{
    services.headscale = {
        enable = true;
        settings = {
            server_url = "https://headscale.eternaladventure.xyz";
            dns.magic_dns = true;
            dns.base_domain = "ts.eternaladventure.xyz";
        };
    };
}