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
    hyprland.url = "github:hyprwm/Hyprland/v0.50.0";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    #chaotic.url = "github:chaotic-cx/nyx/ffeb9f4b6a4bfbf33e9c3f9494aa9f08b4a2da61";

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
      url = "git+ssh://git@github.com/sadroad/.nix-secrets.git";
      flake = false;
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    glimpse = {
      url = "github:seatedro/glimpse/v0.7.8";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nh = {
      url = "github:nix-community/nh";
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
    systems = ["x86_64-linux" "aarch64-darwin"];
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
      pkgs = mkPkgs system;
    in
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = commonSpecialArgs // {inherit hostname userDir;};
        modules = [
          ./hosts/${hostname}/default.nix
          {nixpkgs.pkgs = pkgs;}
          inputs.home-manager.nixosModules.home-manager
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
      pkgs = mkPkgs system;
    in
      inputs.nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = commonSpecialArgs // {inherit hostname userDir;};
        modules = [
          ./hosts/${hostname}/default.nix
          {nixpkgs.pkgs = pkgs;}
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

    nixosConfigurations = {
      piplup = mkNixosSystem {
        hostname = "piplup";
        system = "x86_64-linux";
      };
      serperior = mkNixosSystem {
        hostname = "serperior";
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
