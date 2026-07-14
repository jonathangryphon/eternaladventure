{
  description = "Dope personal nixos configs for the sick personal cloud";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko"; 
    disko.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # lulu (pi5) specific — kept independent on purpose
    rpi.url = "github:nvmd/nixos-raspberrypi/main"; 
  };

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };


  outputs = { self, nixpkgs, sops-nix, disko, rpi, darwin, ... }@inputs: {
    nixosConfigurations = {

      afabel = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ 
            ./hosts/afabel/default.nix
            ./modules/common.nix
        ];
      };

      rosalina = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; # for x86 VPS, I guess I could maybe do aarch
        specialArgs = inputs;
        modules = [
          disko.nixosModules.disko 
          ./hosts/rosalina/default.nix
          ./hosts/rosalina/disko.nix
          ./modules/common.nix
        ];
      };

      rosalina-bootstrap = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          disko.nixosModules.disko
          ./hosts/rosalina/default.nix
          ./hosts/rosalina/disko.nix
          ./modules/common.nix
        ];
      };

      keep = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
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
              raspberry-pi-5.bluetooth
              usb-gadget-ethernet
            ];
          })

          { boot.loader.raspberry-pi.bootloader = "kernel"; }

          ./hosts/lulu/default.nix
          ./modules/common.nix
        ];
      };

    };
    darwinConfigurations = {
      gilbert = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = inputs;
        modules = [
          ./hosts/gilbert/default.nix
        ];
      };
    };
  };
}