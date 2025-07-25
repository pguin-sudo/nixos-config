{
  description = "My NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      # Home Manager release compatible with NixOS 25.05
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs"; # Crucial: HM uses the same nixpkgs
    };
  };

  outputs = { self, nixpkgs, home-manager, ...}@inputs: {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs; # Pass flake inputs (like nixpkgs, home-manager) to your modules
          # You can add other special arguments here if needed by your modules
        };
        modules = [
          # Import your main system configuration file
          ./configuration.nix

          # Import Home Manager's NixOS module to enable Home Manager
          home-manager.nixosModules.home-manager

          # Configure Home Manager itself and define users
          {
            # Allow home.nix to access the system's nixpkgs via 'pkgs'
            home-manager.useGlobalPkgs = true;
            # Allow Home Manager to manage packages for users defined in users.users
            home-manager.useUserPackages = true;

            # Pass flake inputs (like 'inputs.nixpkgs', 'inputs.home-manager')
            # to your home.nix files if they need to reference them directly.
            home-manager.extraSpecialArgs = { inherit inputs; };

            # --- ADDED THIS LINE TO HANDLE EXISTING USER CONFIGURATION FILES ---
            home-manager.backupFileExtension = "hm-bak"; # Or "backup", or any extension you prefer

            # Define your user and point to their Home Manager configuration
            home-manager.users.pguin = import ./users/pguin.nix;
            # (This assumes blfnix.nix is now at /etc/nixos/users/blfnix.nix)
          }

          # If your hardware-configuration.nix is not special and just a local file,
          # it should be imported by configuration.nix itself.
        ];
      };
    };
  };
}


