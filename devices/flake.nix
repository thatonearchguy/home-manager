{
  description = "thatonearchguy NixOS configuration";

  inputs = {
    # NixOS official package source, using nixos-24.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    archix = {
      url = "github:SamLukeYes/archix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixcord = {
      url = "github:4evy/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, archix, home-manager, plasma-manager, nixcord, ... }@inputs:
  let
    mkSystem = name: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        targetDevice = name;
      };
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./core.nix
        archix.nixosModules.default
        home-manager.nixosModules.home-manager ({ config, ...}: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              inherit (config.networking) hostName;
            };
            home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager nixcord.homeModules.nixcord ];
            home-manager.users.kavya = import /home/kavya/.config/home-manager/home.nix;
          # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
        })
      ];
    };

  in {
    nixosConfigurations = {
      Hercules = mkSystem "Hercules";
      RussellHobbs = mkSystem "RussellHobbs";
      Sojourner = mkSystem "Sojourner";
    };
  };
}
