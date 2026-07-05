{
  description = "Dope personal nixos configs for the sick personal cloud";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    sops-nix.url = "github:Mic92/sops-nix/9836912e37aef546029e48c8749834735a6b9dad"; # ???
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko"; 
    disko.inputs.nixpkgs.follows = "nixpkgs";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, sops-nix, disko, unstable, ... }: {
    nixosConfigurations = {

      afabel = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit sops-nix; };
        modules = [ 
            ./configuration.nix 
            ./hosts/afabel.nix
        ];
      };

      rosalina = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; # for x86 VPS, I guess I could maybe do aarch
        specialArgs = { inherit sops-nix; };
        modules = [
          disko.nixosModules.disko 
          ./configuration.nix
          ./hosts/rosalina.nix
          ./hosts/hardware-rosalina.nix
        ];
      };

      rosalina-bootstrap = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit sops-nix; };
        modules = [
          disko.nixosModules.disko
          ./configuration-bootstrap.nix
          ./hosts/rosalina.nix
          ./hosts/hardware-rosalina.nix
        ];
      };

      keep = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit sops-nix; };
        modules = [
          ./boostrap-keep.nix
          ./hosts/keep.nix
          ./hosts/hardware-keep.nix
        ];
      };

    };
  };
}