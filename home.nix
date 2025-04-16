{
  config,
  lib,
  pkgs,
  username,
  inputs,
  osConfig,
  ...
}: let
  decryptedKeyPath = osConfig.age.secrets."sadroad-gpg-private".path;
  importScript = ./import-gpg-key.sh;
in rec {
  home.packages = with pkgs; [
    neofetch
    btop
    brave
    bemenu
    file
    delta

    git-secrets

    eza
    dust
    ripgrep
    fd
    procs
    gping
    _0x
    pigz
    bat
    doggo

    waybar
  ];

  imports = [
    ./hyprland.nix
    ./waybar
  ];

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "off";
      preload = [
        "${osConfig.age.secrets."1.jpg".path}"
        "${osConfig.age.secrets."change.jpg".path}"
      ];
      wallpaper = [
        "DP-3, ${osConfig.age.secrets."change.jpg".path}"
        "DP-1, ${osConfig.age.secrets."1.jpg".path}"
      ];
    };
  };

  programs.ghostty = {
    enable = true;
    settings = {
      shell-integration-features = "sudo";
      command = "fish --login --interactive";
      theme = "GruvboxDark";
      font-family = "Berkeley Mono Variable";
      font-style = "Retina";
      font-size = "14";
    };
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host tux
      	HostName tux.cs.drexel.edu
      	User av676
    '';
  };

  programs.fzf = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
  };

  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
    defaultCacheTtl = 4 * 60 * 60; # 4 hours
  };

  systemd.user.services.import-gpg-key = {
    Unit = {
      Description = "Import GPG private key from agenix secret";
      After = ["gpg-agent.service"];
      Requires = ["gpg-agent.service"];
      ConditionPathExists = decryptedKeyPath;
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = false;
      ExecStart = "${importScript} ${decryptedKeyPath}";
      Environment = "PATH=${lib.makeBinPath [pkgs.gnupg pkgs.gnugrep pkgs.coreutils]}";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      ui = {
        pager = "delta";
      };
      user = {
        name = "Alex Villablanca";
        email = "alex@villablanca.tech";
      };
      git = {
        subprocess = true;
        sign-on-push = true;
      };
      signing = {
        behavoir = "drop";
        key = "2B826E3C035C8BB5";
        backend = "gpg";
      };
    };
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      reload = "source ~/.config/fish/config.fish";
      mkdir = "mkdir -p";
      type = "type -a";
    };
    shellAliases = {
      ls = "eza";
      l = "eza -lah";
      cat = "bat";
      grep = "rg";
      tree = "eza --tree";
      top = "btop";
      du = "dust";
      vim = "nvim";
      vi = "nvim";
      xxd = "0x";
      find = "fd";
      cd = "z";
      dig = "doggo";
      ps = "procs";
      ping = "gping";
      diff = "delta";
      gzip = "pigz";
    };
  };

  programs.tealdeer = {
    enable = true;
    enableAutoUpdates = true;
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    flake = "${home.homeDirectory}/.dotfiles";
  };

  programs.atuin = {
    daemon.enable = true;
    enable = true;
    flags = ["--disable-up-arrow"];
    settings = {
      sync_address = "https://atuin.local.villablanca.tech";
      enter_accept = false;
      sync = {
        records = true;
      };
      dotfiles.enable = false;
    };
  };

  home.shell.enableFishIntegration = true;

  fonts.fontconfig.enable = true;

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.sessionVariables.NIXOS_ZONE_WL = "1";

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
