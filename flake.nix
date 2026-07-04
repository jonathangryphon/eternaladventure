{
  description = "Dope personal nixos configs for the sick personal cloud";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    sops-nix.url = "github:Mic92/sops-nix/9836912e37aef546029e48c8749834735a6b9dad"; # ???
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko"; 
    disko.inputs.nixpkgs.follows = "nixpkgs";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    hermes-agent.inputs.nixpkgs.follows = "unstable";
  };

  outputs = { self, nixpkgs, sops-nix, disko, unstable, hermes-agent, ... }: {
    nixosConfigurations = {

      afabel = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit sops-nix; };
        modules = [ 
              ({ pkgs, ... }: {
                nixpkgs.overlays = [
                  (final: prev: {
                    unstable = import unstable { system = prev.system; config.allowUnfree = prev.config.allowUnfree or false; };
                  })
                ];
              })
            hermes-agent.nixosModules.default
            ./configuration.nix 
            ./hosts/afabel.nix
            ./modules/hermes.nix
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
    };
  };
}