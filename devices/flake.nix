{
  description = "thatonearchguy NixOS configuration";

  inputs = {
    # NixOS official package source, using nixos-24.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, ... }@inputs: {
    # Please replace my-nixos with your hostname
    nixosConfigurations = {
      Hercules = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect
          ./core.nix
          home-manager.nixosModules.home-manager ({ config, ...}: {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                inherit (config.networking) hostName;
              };
              home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
              # TODO replace ryan with your own username
              home-manager.users.kavya = import /home/kavya/.config/home-manager/home.nix;
            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          })
        ];
      };
    };
  };
}
