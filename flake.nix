{
  description = "Dope personal nixos configs for the sick personal cloud";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    sops-nix.url = "github:Mic92/sops-nix/9836912e37aef546029e48c8749834735a6b9dad"; # ???
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko"; 
    disko.inputs.nixpkgs.follows = "nixpkgs";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # lulu (pi5) specific — kept independent on purpose
    nixpkgs-lulu.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    rpi.url = "github:nvmd/nixos-raspberrypi/main";
    sops-nix-lulu.url = "github:Mic92/sops-nix";
    sops-nix-lulu.inputs.nixpkgs.follows = "nixpkgs-lulu";  
  };

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };


  outputs = { self, nixpkgs, sops-nix, disko, unstable, nixpkgs-lulu, rpi, sops-nix-lulu, ... }@inputs: {
    nixosConfigurations = {

      afabel = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit sops-nix; };
        modules = [ 
            ./hosts/afabel/default.nix
            ./modules/common.nix
        ];
      };

      rosalina = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; # for x86 VPS, I guess I could maybe do aarch
        specialArgs = { inherit sops-nix; };
        modules = [
          disko.nixosModules.disko 
          ./hosts/rosalina/default.nix
          ./hosts/rosalina/disko.nix
          ./modules/common.nix
        ];
      };

      rosalina-bootstrap = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit sops-nix; };
        modules = [
          disko.nixosModules.disko
          ./hosts/rosalina/default.nix
          ./hosts/rosalina/disko.nix
          ./modules/common.nix
        ];
      };

      keep = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit sops-nix; };
        modules = [
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
          ./hosts/keep/default.nix
          ./hosts/keep/disko.nix
          ./hosts/keep/hardware-configuration.nix
          ./modules/common.nix
        ];
      };

      lulu = rpi.lib.nixosSystemFull {
        system = "aarch64-linux";
        specialArgs = inputs;

        modules = [
          ({ config, pkgs, lib, rpi, ... }: {
            imports = with rpi.nixosModules; [
              raspberry-pi-5.base
              raspberry-pi-5.page-size-16k
              raspberry-pi-5.display-vc4
              raspberry-pi-5.bluetooth
              usb-gadget-ethernet
            ];
          })

          sops-nix-lulu.nixosModules.sops

          ./hosts/lulu/hardware-configuration.nix
          ./hosts/lulu/pi5-configtxt.nix

          { boot.loader.raspberry-pi.bootloader = "kernel"; }
          ./hosts/lulu/configuration.nix
          # COMMON minus sops. TODO: sort through sops pins, see if we can't use just one. 
          ./modules/users/core.nix
          ./modules/ssh.nix
          ./modules/server_arch.nix
          ./modules/headscale-client.nix
        ];
      };

    };
  };
}