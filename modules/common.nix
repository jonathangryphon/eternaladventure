{config, pkgs, lib,  sops-nix, ... }:

{
    imports = [
        ./users/core.nix
        ./ssh.nix
        ./server_arch.nix
        "${sops-nix}/modules/sops"
        ./sops.nix
        ./headscale-client.nix
        # ./oink_ddns.nix NETWORKING: all routed via VPS static IP 
    ];

    networking.firewall.allowedTCPPorts = [ 80 443 ]; # base ports
    i18n.defaultLocale = "en_US.UTF-8";

    # SECURITY
    security.sudo.enable = true;
    security.sudo.wheelNeedsPassword = false; # sudo defaults to psw auth, but systems are ssh-key auth only
    nix.settings.trusted-users = [ "charity" ];

    # FLAKE SUPPORT
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # NIX PACKAGES
    nixpkgs.config.allowUnfree = true;
    # BASE PACKAGES
    environment.systemPackages = with pkgs; [
        # Core CLI
        vim git wget btop neofetch

        # Secrets
        sops age
    ];
}