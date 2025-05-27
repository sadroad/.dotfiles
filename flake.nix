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
    hyprland.url = "github:hyprwm/Hyprland/v0.49.0";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    # nix-darwin
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
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
      url = "github:ryantm/agenix/96e078c646b711aee04b82ba01aefbff87004ded";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    my_secrets = {
      url = "git+ssh://git@github.com/sadroad/nix-secrets.git";
      flake = false;
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nh = {
      url = "github:nix-community/nh";
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
    mac-app-util,
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
            inherit hostname username userDir inputs agenix my_secrets;
          };
          modules = [
            ./hosts/${hostname}/default.nix

            {nixpkgs.pkgs = pkgs;}

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
                inherit username inputs agenix userDir system;
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
            inherit hostname username userDir inputs agenix my_secrets;
          };
          modules = [
            ./hosts/${hostname}/default.nix

            {nixpkgs.pkgs = pkgs;}

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
              home-manager.sharedModules = [
                mac-app-util.homeManagerModules.default
              ];
              home-manager.extraSpecialArgs = {
                inherit username inputs agenix userDir system;
                osConfig = config;
              };
            })
          ];
        };
    };
  };
}
