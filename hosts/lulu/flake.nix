{
  description = "Lulu: the raspberry pi 5 backup server flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    rpi.url = "github:nvmd/nixos-raspberrypi/main";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Optional: Binary cache for the rpi flake
  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs = { self, nixpkgs, rpi, sops-nix, ... }@ inputs: 
  let
    system = "aarch64-linux";
  in { 
    nixosConfigurations = {

      lulu = rpi.lib.nixosSystemFull {
        inherit system;
        specialArgs = inputs;

        modules = [
          # raspberry-pi flake modules
          ({ config, pkgs, lib, rpi, ... }: {
            imports = with rpi.nixosModules; [
              # Hardware configurations
              raspberry-pi-5.base
              raspberry-pi-5.page-size-16k
              raspberry-pi-5.display-vc4
              raspberry-pi-5.bluetooth
              usb-gadget-ethernet # Configures USB Gadget/Ethernet - Ethernet emulation over USB
              ];
          })
          
          sops-nix.nixosModules.sops

          # personal additions 
          ./hardware-configuration.nix
 
          # my pi5 config.txt 
          ./pi5-configtxt.nix

          # Change default bootloader according to documentation recommendation
          { boot.loader.raspberry-pi.bootloader = "kernel"; }
       
          # Import all non-hardware related configurations (users, ssh, services, ... )
          ./configuration.nix 
        ];
      };
    };
  };
}
