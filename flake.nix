{
  inputs = {
    # core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixos
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland/v0.48.1"; # Note: Check if this version is still current
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # shared
    agenix = {
      # Consider using a more stable ref like a tag if available
      url = "github:ryantm/agenix/564595d0ad4be7277e07fa63b5a991b3c645655d";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    my_secrets = {
      url = "git+ssh://git@github.com/sadroad/nix-secrets.git?shallow=1";
      flake = false;
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    agenix,
    my_secrets,
    nix-darwin,
    ...
  }: let
    username = "sadroad";

    systems = ["x86_64-linux" "aarch64-darwin"];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    mkPkgs = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
  in {
    formatter = forAllSystems (system: (mkPkgs system).alejandra);

    nixosConfigurations = {
      piplup = let
        system = "x86_64-linux";
        hostname = "piplup";
        userDir = "/home/${username}";
        pkgs = mkPkgs system;
      in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit hostname username userDir inputs agenix my_secrets pkgs;
          };
          modules = [
            ./hosts/${hostname}/default.nix

            home-manager.nixosModules.home-manager
            ({
              config,
              pkgs,
              lib,
              ...
            }: {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = ./modules/home-manager/default.nix;
              home-manager.extraSpecialArgs = {
                inherit username inputs agenix userDir;
                osConfig = config;
              };
            })
          ];
        };
    };

    darwinConfigurations = {
      R2D2 = let
        system = "aarch64-darwin";
        hostname = "R2D2";
        userDir = "/Users/${username}";
        pkgs = mkPkgs system;
      in
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit hostname username userDir inputs agenix my_secrets pkgs;
          };
          modules = [
            ./hosts/${hostname}/default.nix

            home-manager.darwinModules.home-manager
            ({
              config,
              pkgs,
              lib,
              ...
            }: {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = ./modules/home-manager/default.nix;
              home-manager.extraSpecialArgs = {
                inherit username inputs agenix userDir;
                osConfig = config;
              };
            })
          ];
        };
    };
  };
}
