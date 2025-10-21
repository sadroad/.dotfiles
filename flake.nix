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
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";
    hyprland = {
      # url = "github:hyprwm/Hyprland/v0.51.1";
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    elephant = {
      url = "github:abenz1267/elephant/v2.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    walker = {
      url = "github:abenz1267/walker/v2.2.0";
      inputs.elephant.follows = "elephant";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #darwin
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
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
      url = "git+ssh://git@github.com/sadroad/.nix-secrets.git";
      flake = false;
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty/v1.2.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

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
          inputs.nix-index-database.nixosModules.nix-index
          ({config, ...}: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} =
              ./modules/home-manager/default.nix;
            home-manager.extraSpecialArgs =
              commonSpecialArgs
              // {
                inherit userDir system hostname;
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
          ({config, ...}: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} =
              ./modules/home-manager/default.nix;
            home-manager.sharedModules = [
              inputs.mac-app-util.homeManagerModules.default
            ];
            home-manager.extraSpecialArgs =
              commonSpecialArgs
              // {
                inherit userDir system hostname;
                osConfig = config;
              };
          })
        ];
      };
  in {
    formatter = forAllSystems (system: (mkPkgs system).alejandra);

    devShells = forAllSystems (system: let
      pkgs = mkPkgs system;
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixd
          alejandra
        ];
      };
    });

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
}
