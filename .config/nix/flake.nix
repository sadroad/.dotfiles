{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    cloudflare-tmp.url = "github:NixOS/nixpkgs/6c5963357f3c1c840201eda129a99d455074db04";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
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
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    homebrew-bundle,
    cloudflare-tmp,
    ...
  }: let
    system = "aarch64-darwin";

    pkgs-cloudflare-tmp = import cloudflare-tmp {
      inherit system;
    };

    configuration = {pkgs, ...}: {
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        neovim
        fish
        atuin
        bats
        btop
        bun
        pkgs-cloudflare-tmp.cloudflared
        curl
        doggo
        fastfetch
        fzf
        git
        delta
        ijq
        infisical
        jujutsu
        file
        miniserve
        yazi
        stow
        bat
        zoxide
        tealdeer
        eza
        dust
        fd
        ripgrep
        procs
        mdbook
        hyperfine
        gping
        _0x
        pigz
        nodejs_22
        rustscan
        zig
        vscode
      ];

      users.knownUsers = ["sadroad"];
      users.users.sadroad.uid = 501;
      users.users.sadroad.shell = pkgs.fish;

      homebrew = {
        enable = true;
        brews = [
          "podman"
          "podman-compose"
        ];
        casks = [
          "ghostty"
          "iina"
          "raycast"
          "alt-tab"
          "imhex"
          "gpg-suite-no-mail"
          "podman-desktop"
        ];
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      system.defaults = {
        dock.autohide = true;
      };

      nix.enable = false;
      nix.settings.experimental-features = "nix-command flakes";

      programs.fish.enable = true;

      system.configurationRevision = self.rev or self.dirtyRev or null;

      system.stateVersion = 6;

      nixpkgs.hostPlatform = system;
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#R2D2
    darwinConfigurations."R2D2" = nix-darwin.lib.darwinSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ({config, ...}: {
          homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
        })
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "sadroad";
            autoMigrate = true;
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
            };
            mutableTaps = false;
          };
        }
      ];
    };

    darwinPackages = self.darwinConfigurations."R2D2".pkgs;
  };
}

