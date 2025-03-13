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
    acrogenesis-macchanger = {
      url = "github:acrogenesis/homebrew-macchanger";
      flake = false;
    };
    akeru-inc-tap = {
      url = "github:akeru-inc/homebrew-tap";
      flake = false;
    };
    apple-apple = {
      url = "github:apple/homebrew-apple";
      flake = false;
    };
    chiselstrike-tap = {
      url = "github:chiselstrike/homebrew-tap";
      flake = false;
    };
    gcenx-wine = {
      url = "github:gcenx/homebrew-wine";
      flake = false;
    };
    goodwithtech-r = {
      url = "github:goodwithtech/homebrew-r";
      flake = false;
    };
    goreleaser-tap = {
      url = "github:goreleaser/homebrew-tap";
      flake = false;
    };
    hudochenkov-sshpass = {
      url = "github:hudochenkov/homebrew-sshpass";
      flake = false;
    };
    infisical-get-cli = {
      url = "github:infisical/homebrew-get-cli";
      flake = false;
    };
    jzaleski-jzaleski = {
      url = "github:jzaleski/homebrew-jzaleski";
      flake = false;
    };
    koekeishiya-formulae = {
      url = "github:koekeishiya/homebrew-formulae";
      flake = false;
    };
    libsql-sqld = {
      url = "github:libsql/homebrew-sqld";
      flake = false;
    };
    louisbrunner-valgrind = {
      url = "github:louisbrunner/homebrew-valgrind";
      flake = false;
    };
    netbirdio-tap = {
      url = "github:netbirdio/homebrew-tap";
      flake = false;
    };
    nikitabobko-tap = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    oven-sh-bun = {
      url = "github:oven-sh/homebrew-bun";
      flake = false;
    };
    planetscale-tap = {
      url = "github:planetscale/homebrew-tap";
      flake = false;
    };
    romkatv-powerlevel10k = {
      url = "github:romkatv/homebrew-powerlevel10k";
      flake = false;
    };
    snyk-tap = {
      url = "github:snyk/homebrew-tap";
      flake = false;
    };
    sst-tap = {
      url = "github:sst/homebrew-tap";
      flake = false;
    };
    surrealdb-tap = {
      url = "github:surrealdb/homebrew-tap";
      flake = false;
    };
    teamookla-speedtest = {
      url = "github:teamookla/homebrew-speedtest";
      flake = false;
    };
    wpscanteam-tap = {
      url = "github:wpscanteam/homebrew-tap";
      flake = false;
    };
    yoheimuta-protolint = {
      url = "github:yoheimuta/homebrew-protolint";
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
    acrogenesis-macchanger,
    akeru-inc-tap,
    apple-apple,
    chiselstrike-tap,
    gcenx-wine,
    goodwithtech-r,
    goreleaser-tap,
    hudochenkov-sshpass,
    infisical-get-cli,
    jzaleski-jzaleski,
    koekeishiya-formulae,
    libsql-sqld,
    louisbrunner-valgrind,
    netbirdio-tap,
    nikitabobko-tap,
    oven-sh-bun,
    planetscale-tap,
    romkatv-powerlevel10k,
    snyk-tap,
    sst-tap,
    surrealdb-tap,
    teamookla-speedtest,
    wpscanteam-tap,
    yoheimuta-protolint,
    ...
  }: let
    configuration = {pkgs, ...}: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        pkgs.neovim
        pkgs.fish
      ];

      users.knownUsers = ["sadroad"];
      users.users.sadroad.uid = 501;
      users.users.sadroad.shell = pkgs.fish;

      homebrew = {
        enable = true;
        casks = [
          "ghostty"
        ];
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
              "acrogenesis/homebrew-macchanger" = acrogenesis-macchanger;
              "akeru-inc/homebrew-tap" = akeru-inc-tap;
              "apple/homebrew-apple" = apple-apple;
              "chiselstrike/homebrew-tap" = chiselstrike-tap;
              "gcenx/homebrew-wine" = gcenx-wine;
              "goodwithtech/homebrew-r" = goodwithtech-r;
              "goreleaser/homebrew-tap" = goreleaser-tap;
              "hudochenkov/homebrew-sshpass" = hudochenkov-sshpass;
              "infisical/homebrew-get-cli" = infisical-get-cli;
              "jzaleski/homebrew-jzaleski" = jzaleski-jzaleski;
              "koekeishiya/homebrew-formulae" = koekeishiya-formulae;
              "libsql/homebrew-sqld" = libsql-sqld;
              "louisbrunner/homebrew-valgrind" = louisbrunner-valgrind;
              "netbirdio/homebrew-tap" = netbirdio-tap;
              "nikitabobko/homebrew-tap" = nikitabobko-tap;
              "oven-sh/homebrew-bun" = oven-sh-bun;
              "planetscale/homebrew-tap" = planetscale-tap;
              "romkatv/homebrew-powerlevel10k" = romkatv-powerlevel10k;
              "snyk/homebrew-tap" = snyk-tap;
              "sst/homebrew-tap" = sst-tap;
              "surrealdb/homebrew-tap" = surrealdb-tap;
              "teamookla/homebrew-speedtest" = teamookla-speedtest;
              "wpscanteam/homebrew-tap" = wpscanteam-tap;
              "yoheimuta/homebrew-protolint" = yoheimuta-protolint;
            };
            mutableTaps = false;
          };
        }
      ];
    };

    darwinPackages = self.darwinConfigurations."R2D2".pkgs;
  };
}

