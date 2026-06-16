{
  description = "Afabel NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, sops-nix }: {
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
        system = "x86_64-linux";
        specialArgs = { inherit sops-nix; };
        modules = [
          ./configuration.nix
          ./hosts/rosalina.nix
        ];
      };

    };
  };
}