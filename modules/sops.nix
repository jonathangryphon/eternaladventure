{ config, pkgs, lib, ... }:

{
  sops.age.keyFile = "/etc/nixos/secrets/keys.txt";
}
