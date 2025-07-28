{
  description = "My NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs"; 
    };

    stylix.url = "github:danth/stylix/release-25.05";
  };

  outputs = { self, nixpkgs, home-manager, stylix, ...}@inputs:
  let 
    hostname = "desktop";
    user = "pguin";
  in {
    nixosConfigurations = {
      "${hostname}" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./configuration-hosts/${hostname}/configuration.nix
          home-manager.nixosModules.home-manager
          stylix.nixosModules.stylix

          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              extraSpecialArgs = { inherit inputs; };

              backupFileExtension = "hm-backup"; 

              users.pguin = import ./home-users/${user}.nix;
            };
          }
        ];
      };
    };
  };
}


