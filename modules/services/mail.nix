{ config, pkgs, ... }:

{
    services.stalwart-mail = {
        enable = true;
        openFirewall = true;
        hostname = "mail.eternaladventure.xyz"
        primaryDomain = "eternaladventure.xyz"

        tls = {
            enable = true;
            mode = "acme";
            acmeEmail = "admin@eternaladventure.xyz"
        };

        storage = {
            type = "maildir";
            path = "/tank/services/mail";
        };

        auth = {
            type = "passwd";
        }


    }
}