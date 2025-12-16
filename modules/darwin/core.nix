{
  config,
  pkgs,
  lib,
  username,
  userDir,
  secretsAvailable,
  ...
}: {
  nix.settings = {
    accept-flake-config = true;
  };

    nix.settings = {
    experimental-features = ["nix-command" "flakes" "external-builders"];
    external-builders = [
      {
        systems = ["aarch64-linux" "x86_64-linux"];
        program = "/usr/local/bin/determinate-nixd";
        args = ["builder"];
      }
    ];
  };

  determinate-nix.customSettings =
    {
      eval-cores = 0;
      substituters = [];
      trusted-public-keys = [];
    }
    // lib.optionalAttrs
    secretsAvailable {
      access-tokens = "!include ${config.age.secrets."github_oauth".path}";
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
