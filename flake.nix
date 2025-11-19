{
  outputs = inputs: let
    secretsEval = builtins.tryEval inputs.my_secrets;
    secretsAvailable = secretsEval.success;
    secretsPath =
      if secretsAvailable
      then secretsEval.value
      else null;

    username = "sadroad";
    systems = ["x86_64-linux" "aarch64-darwin" "aarch64-linux"];
    forAllSystems = inputs.nixpkgs.lib.genAttrs systems;

    mkPkgs = system:
      import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    commonSpecialArgs = {
      inherit username inputs secretsAvailable secretsPath;
      agenix = inputs.agenix;
    };

    mkNixosSystem = {
      hostname,
      system,
    }: let
      userDir = "/home/${username}";
    in
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = commonSpecialArgs // {inherit hostname userDir;};
        modules = [
          ./hosts/${hostname}/default.nix
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [(import ./overlays/default.nix)];
          }
          inputs.home-manager.nixosModules.home-manager
          inputs.determinate.nixosModules.default
          inputs.nix-index-database.nixosModules.nix-index
          inputs.chaotic.nixosModules.default
          ({config, pkgs, ...}: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.sharedModules = [
              inputs.nix-index-database.homeModules.nix-index
            ];
            home-manager.users.${username} =
              ./modules/home-manager/default.nix;
            home-manager.extraSpecialArgs =
              commonSpecialArgs
              // {
                inherit userDir system hostname pkgs;
                osConfig = config;
              };
          })
        ];
      };

    mkDarwinSystem = {
      hostname,
      system,
    }: let
      userDir = "/Users/${username}";
    in
      inputs.nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = commonSpecialArgs // {inherit hostname userDir;};
        modules = [
          ./hosts/${hostname}/default.nix
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [(import ./overlays/default.nix)];
            nix.enable = false;
            determinate-nix.customSettings = {
            };
          }
          inputs.determinate.darwinModules.default
          inputs.nix-index-database.darwinModules.nix-index
          inputs.home-manager.darwinModules.home-manager
          ({config, pkgs, ...}: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} =
              ./modules/home-manager/default.nix;
            home-manager.sharedModules = [
              inputs.mac-app-util.homeManagerModules.default
              inputs.nix-index-database.homeModules.nix-index
            ];
            home-manager.extraSpecialArgs =
              commonSpecialArgs
              // {
                inherit userDir system hostname pkgs;
                osConfig = config;
              };
          })
        ];
      };
  in {
    formatter = forAllSystems (system: (mkPkgs system).alejandra);

    nixosConfigurations = {
      piplup = mkNixosSystem {
        hostname = "piplup";
        system = "x86_64-linux";
      };
    };

    darwinConfigurations = {
      R2D2 = mkDarwinSystem {
        hostname = "R2D2";
        system = "aarch64-darwin";
      };
    };
  };
  inputs = {
    # core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    winboat-nixpkgs.url = "github:nixos/nixpkgs/c5ae371f1a6a7fd27823bc500d9390b38c05fa55";

    # nixos
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.52.1";
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    elephant.url = "github:abenz1267/elephant/v2.13.2";
    walker = {
      url = "github:abenz1267/walker/v2.8.2";
      inputs.elephant.follows = "elephant";
    };
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    #darwin
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.cl-nix-lite.url = "github:r4v3n6101/cl-nix-lite/url-fix";
    };

    # shared
    agenix.url = "github:ryantm/agenix/96e078c646b711aee04b82ba01aefbff87004ded";
    my_secrets = {
      url = "git+ssh://git@github.com/sadroad/.nix-secrets.git";
      flake = false;
    };
    nvf = {
      url = "github:notashelf/nvf/v0.8";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty.url = "github:ghostty-org/ghostty/v1.2.3";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nh = {
      url = "github:nix-community/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-index-database.follows = "nix-index-database";
    };
    opencode = {
      url = "github:sst/opencode";
    };
  };
}
