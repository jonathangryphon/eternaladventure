{
  description = "Afabel NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    sops-nix.url = "github:Mic92/sops-nix/9836912e37aef546029e48c8749834735a6b9dad";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    disko-url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, sops-nix, disko }: {
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
          ./disks/rosalina-disk.nix
        ];
      };

      rosalina-local = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";  # for UTM on M1
        specialArgs = { inherit sops-nix; };
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          ./hosts/rosalina-local.nix
        ];
      };
    };
  };
}