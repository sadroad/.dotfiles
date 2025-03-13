{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
    ...
  }: let
    configuration = {pkgs, ...}: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        pkgs.neovim
        pkgs.fish
        pkgs.atuin
        pkgs.automake
        pkgs.bats
        pkgs.btop
        pkgs.bun
        pkgs.bzip2
        pkgs.ccache
        pkgs.chafa
        pkgs.cloudflared
        pkgs.cmake
        pkgs.cmocka
        pkgs.curl
        pkgs.doggo
        pkgs.fastfetch
        pkgs.fzf
        pkgs.git
        pkgs.delta
        pkgs.glfw
        pkgs.ijq
        pkgs.imagemagick
        pkgs.infisical
        pkgs.jujutsu
        pkgs.file
        pkgs.gnumake
        pkgs.meson
        pkgs.miniserve
        pkgs.uv
        pkgs.yazi
        pkgs.zig
        pkgs.fnm
        pkgs.stow
      ];

      users.knownUsers = ["sadroad"];
      users.users.sadroad.uid = 501;
      users.users.sadroad.shell = pkgs.fish;

      homebrew = {
        enable = true;
        casks = [
          "ghostty"
          "iina"
          "raycast"
          "alt-tab"
          "imhex"
          "gpg-suite-no-mail"
        ];
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      system.defaults = {
        dock.autohide = true;
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#R2D2
    darwinConfigurations."R2D2" = nix-darwin.lib.darwinSystem {
      modules = [
        ({ config, ... }: {                                                          # <--
          homebrew.taps = builtins.attrNames config.nix-homebrew.taps;               # <--
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

