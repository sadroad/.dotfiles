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
    hyprland.url = "github:hyprwm/Hyprland/v0.48.1";
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
    systems = ["x86_64-linux" "aarch64-darwin"];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});

    system =
      if pkgs.stdenv.isDarwin
      then "aarch64-darwin"
      else "x86_64-linux";

    hostname =
      if pkgs.stdenv.isDarwin
      then "R2D2"
      else "piplup";
    username = "sadroad";
  in {
    formatter = pkgs.alejandra;

    overlays = {
      default = final: prev: {
        vesktop = (import ./overlays/vesktop.nix {inherit inputs;}).vesktop final prev;
      };
    };

    nixosConfigurations = {
      ${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit hostname username inputs agenix my_secrets;
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [self.overlays.default];
          };
        };
        modules = [
          ./hosts/${hostname}/default.nix

          home-manager.nixosModules.home-manager
          ({config, ...}: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./modules/home-manager/default.nix {
              pkgs = import nixpkgs {
                inherit system;
                config.allowUnfree = true;
                overlays = [self.overlays.default];
              };
              lib = nixpkgs.lib;
              inherit inputs username;
            };
            home-manager.extraSpecialArgs = {
              inherit username inputs agenix;
            };
          })
        ];
      };
    };
    darwinConfigurations = {
      R2D2 = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit inputs username hostname;
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [self.overlays.default];
          };
        };
        modules = [
          ./hosts/R2D2/default.nix

          home-manager.darwinModules.home-manager
          ({config, ...}: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./modules/home-manager/default.nix {
              pkgs = import nixpkgs {
                inherit system;
                config.allowUnfree = true;
                overlays = [self.overlays.default];
              };
              lib = nixpkgs.lib;
              inherit inputs username;
            };
            home-manager.extraSpecialArgs = {
              inherit username inputs agenix;
            };
          })
        ];
      };
    };
  };
}
