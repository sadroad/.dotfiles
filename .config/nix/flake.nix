{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin= {
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
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    homebrew-bundle,
    mac-app-util,
    ...
  }: let
    system = "aarch64-darwin";

    vesktop-overlay = final: prev: {
      # Target the 'vesktop' package
      vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
        # Add a postPatch hook. This runs after unpacking and applying upstream patches.
        postPatch = ''
          echo "Applying custom shiggy.gif patch to Vesktop"
          # Ensure the target directory exists (it should, but good practice)
          mkdir -p static
          # Remove the original file (-f ignores errors if it doesn't exist)
          rm -f static/shiggy.gif
          # Copy the replacement file. Nix automatically copies ./shiggy.gif
          # into the Nix store and substitutes the correct path here.
          cp ${./shiggy.gif} static/shiggy.gif
          echo "Successfully replaced static/shiggy.gif"
        '';
        # If the upstream derivation changes significantly, you might need to
        # adjust the path 'static/shiggy.gif' here.
      });
    };

    configuration = {pkgs, lib, ...}: let
    in {
      nixpkgs.overlays = [ vesktop-overlay ];

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
        cloudflared
        qbittorrent
        curl
        pv
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
        vscode
        vesktop
        viu
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
        mac-app-util.darwinModules.default
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
