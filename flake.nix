{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland/v0.48.1";
    agenix = {
      url = "github:ryantm/agenix/564595d0ad4be7277e07fa63b5a991b3c645655d";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    my_secrets = {
      url = "git+ssh://git@github.com/sadroad/nix-secrets.git?shallow=1";
      flake = false;
    };
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    disko,
    home-manager,
    agenix,
    my_secrets,
    determinate,
    ...
  }: let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = nixpkgs.legacyPackages.${system};
    hostname = "piplup";
    username = "sadroad";
  in {
    formatter.${system} = pkgs.alejandra;

    nixosConfigurations = {
      ${hostname} = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit hostname username inputs agenix my_secrets;
        };
        modules = [
          disko.nixosModules.disko
          ./disko-config.nix
          ./secrets/nixos.nix
          ./configuration.nix
          determinate.nixosModules.default
          home-manager.nixosModules.home-manager
          ({config, ...}: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = ./home.nix;
            home-manager.extraSpecialArgs = {
              inherit username inputs agenix;
              osConfig = config;
            };
          })
        ];
      };
    };
  };
}
