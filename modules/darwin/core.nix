{
  config,
  pkgs,
  lib,
  inputs,
  username,
  userDir,
  secretsAvailable,
  ...
}: let
  inherit (lib) concatStringsSep filterAttrs isType mapAttrs mapAttrsToList;
  registryMap = filterAttrs (_: v: isType v "flake") inputs;
in {
  nix.package = inputs.nix.packages.${pkgs.stdenv.hostPlatform.system}.default;

  nix.settings =
    {
      accept-flake-config = true;
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["@admin"];
      http-connections = 50;
      lazy-trees = true;
      builders-use-substitutes = true;
      flake-registry = "";
      show-trace = true;
      warn-dirty = false;
    }
    // lib.optionalAttrs secretsAvailable {
      access-tokens = "!include ${config.age.secrets."github_oauth".path}";
    };

  nix.optimise.automatic = true;

  nix.nixPath = concatStringsSep ":" (mapAttrsToList (name: value: "${name}=${value}") registryMap);

  nix.registry = mapAttrs (_: flake: {inherit flake;}) (registryMap // {default = inputs.nixpkgs;});

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 3d";
  };

  system.primaryUser = username;
  users = {
    knownUsers = [username];
    users.${username} = {
      uid = 501;
      home = userDir;
      shell = pkgs.zsh;
    };
  };

  launchd.daemons.limit-maxfiles = {
    script = ''
      /bin/launchctl limit maxfiles 524288 524288
    '';
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
      Label = "org.nixos.limit-maxfiles";
      StandardOutPath = "/var/log/limit-maxfiles.log";
      StandardErrorPath = "/var/log/limit-maxfiles.log";
    };
  };

  environment.shellInit = ''
    ulimit -n 524288
  '';

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];
  system.defaults = {
    NSGlobalDomain.NSWindowResizeTime = 0.001;
    CustomSystemPreferences."com.apple.Accessibility".ReduceMotionEnabled = 1;
    universalaccess.reduceMotion = true;
  };
}
