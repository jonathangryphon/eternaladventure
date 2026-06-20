{ lib, ... }:

{
  imports = [
    ./modules/server_arch.nix
    ./modules/ssh.nix
    "${sops-nix}/modules/sops"
    ./sops-secrets.nix
    ./modules/sops.nix
    ./users.nix
    ./modules/zfs.nix
  ];
}