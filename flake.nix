{
  outputs =
    inputs:
    let
      secretsEval = builtins.tryEval inputs.my_secrets;
      secretsAvailable = secretsEval.success;
      secretsPath = if secretsAvailable then secretsEval.value else null;

      username = "sadroad";
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
        "aarch64-linux"
      ];
      forAllSystems = inputs.nixpkgs.lib.genAttrs systems;

      mkPkgs =
        system:
        import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      commonSpecialArgs = {
        inherit
          username
          inputs
          secretsAvailable
          secretsPath
          ;
        inherit (inputs) agenix;
      };

      mkNixosSystem =
        {
          hostname,
          system,
        }:
        let
          userDir = "/home/${username}";
        in
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = commonSpecialArgs // {
            inherit hostname userDir;
          };
          modules = [
            ./hosts/${hostname}/default.nix
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = [ (import ./overlays/default.nix inputs) ];
            }
            inputs.home-manager.nixosModules.home-manager
            inputs.nix-index-database.nixosModules.nix-index
            inputs.chaotic.nixosModules.default
            (
              {
                config,
                pkgs,
                ...
              }:
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "backup";
                  sharedModules = [
                    inputs.nix-index-database.homeModules.nix-index
                  ];
                  users.${username} = ./modules/home-manager/default.nix;
                  extraSpecialArgs = commonSpecialArgs // {
                    inherit
                      userDir
                      system
                      hostname
                      pkgs
                      ;
                    osConfig = config;
                  };
                };
              }
            )
          ];
        };

      mkDarwinSystem =
        {
          hostname,
          system,
        }:
        let
          userDir = "/Users/${username}";
        in
        inputs.nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = commonSpecialArgs // {
            inherit hostname userDir;
          };
          modules = [
            ./hosts/${hostname}/default.nix
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = [ (import ./overlays/default.nix inputs) ];
            }
            inputs.nix-index-database.darwinModules.nix-index
            inputs.home-manager.darwinModules.home-manager
            (
              {
                config,
                pkgs,
                ...
              }:
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "backup";
                  users.${username} = ./modules/home-manager/default.nix;
                  sharedModules = [
                    inputs.mac-app-util.homeManagerModules.default
                    inputs.nix-index-database.homeModules.nix-index
                  ];
                  extraSpecialArgs = commonSpecialArgs // {
                    inherit
                      userDir
                      system
                      hostname
                      pkgs
                      ;
                    osConfig = config;
                  };
                };
              }
            )
          ];
        };
    in
    {
      formatter = forAllSystems (system: (mkPkgs system).nixfmt-tree);

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

    # nixos
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";

    hyprland = {
      url = "github:hyprwm/Hyprland/v0.53.1";
    };
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # darwin
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs = {
        cl-nix-lite.url = "github:r4v3n6101/cl-nix-lite/url-fix";
      };
    };

    # shared
    agenix = {
      url = "github:yaxitech/ragenix/83bccfdea758241999f32869fb6b36f7ac72f1ac";
    };
    my_secrets = {
      url = "git+ssh://git@github.com/sadroad/.nix-secrets.git";
      flake = false;
    };
    nvf = {
      url = "github:notashelf/nvf/v0.8";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty/tip";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nh = {
      url = "github:nix-community/nh/v4.3.0-beta1";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-index-database.follows = "nix-index-database";
    };
    opencode.url = "github:anomalyco/opencode/v1.1.21";
    wakatime-ls = {
      url = "github:mrnossiom/wakatime-ls/b8b9c1e612f198d767a64142f34c33ffbd347fae";
    };
  };
}
