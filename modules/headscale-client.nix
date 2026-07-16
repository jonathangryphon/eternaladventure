{ config, ... }: {
  sops.secrets."headscale/authkey" = {
    sopsFile = ../secrets/headscale_auth_key.yaml;
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."headscale/authkey".path;
    extraUpFlags = [
      "--login-server" "https://headscale.eternaladventure.xyz"
      "--accept-dns=true"
    ];
  };
}