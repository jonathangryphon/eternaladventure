{ config, pkgs, lib, ... }:

{
  sops.age.keyFile = "/etc/nixos/secrets/age-keys.txt";
}
