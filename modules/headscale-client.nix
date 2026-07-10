{ config, ... }: {
  services.tailscale = {
    enable = true;
    extraUpFlags = [
      "--login-server" "https://headscale.eternaladventure.xyz"
      "--accept-dns=true"
    ];
  };
}