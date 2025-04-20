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
  gitName = "Alex Villablanca";
  gitEmail = "alex@villablanca.tech";
  gitSigningKey = "2B826E3C035C8BB5";
  vesktop =
    pkgs.vesktop.overrideAttrs
    (oldAttrs: {
      postPatch = ''
        mkdir -p static #ensuring that the folder exists
        rm -f static/shiggy.gif
        cp ${./shiggy.gif} static/shiggy.gif
      '';
    });
in rec {
  home.packages = with pkgs; [
    neofetch
    btop
    brave
    bemenu
    file
    delta
    vesktop
    wl-clipboard
    grimblast

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

    jq

    yazi
    yaak

    font-awesome
    noto-fonts-cjk-sans

    unzip
    zip
    coreutils
    fontconfig

    spotify

    waybar
  ];

  imports = [
    ./hyprland.nix
    ./waybar
    inputs.nvf.homeManagerModules.default
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

  programs.git = {
    enable = true;
    userEmail = gitEmail;
    userName = gitName;
    delta = {
      enable = true;
      options = {
        navigate = true;
      };
    };
    extraConfig = {
      rerere = {
        enable = true;
      };
      merge = {
        conflictstyle = "diff3";
      };
      diff = {
        colorMoved = "default";
      };
      color = {
        ui = true;
      };
    };
    signing = {
      key = gitSigningKey;
      format = "openpgp";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      ui = {
        pager = "delta";
      };
      user = {
        name = gitName;
        email = gitEmail;
      };
      git = {
        subprocess = true;
        sign-on-push = true;
      };
      signing = {
        behavoir = "drop";
        key = gitSigningKey;
        backend = "gpg";
      };
    };
  };

  home.sessionVariables = {
    DO_NOT_TRACK = 1;
    PAGER = "delta";
    MANPAGER = ''sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman' '';
    fish_greeting = "";
    pure_enable_nixdevshell = "true";
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "pure";
        inherit (pkgs.fishPlugins.pure) src;
      }
    ];
    functions = {
      y = ''
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
      '';
    };
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

  programs.yazi = {
    enable = true;
  };

  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {
      cudaSupport = true;
    };
    plugins = with pkgs.obs-studio-plugins; [wlrobs obs-pipewire-audio-capture];
  };

  home.activation.installBerkleyMonoFont = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "HM Activation: Executing Berkley Mono install script with arguments..."

    # Execute the script, passing the absolute paths as arguments
    # Ensure the order matches the script's expectation ($1, $2, ...)
    # Quoting is good practice, though Nix store paths are usually safe.
    ${./install-berkley-mono.sh} \
      "${pkgs.unzip}/bin/unzip" \
      "${pkgs.coreutils}/bin/mkdir" \
      "${pkgs.coreutils}/bin/cp" \
      "${pkgs.coreutils}/bin/rm" \
      "${pkgs.coreutils}/bin/chmod" \
      "${pkgs.coreutils}/bin/find" \
      "${pkgs.coreutils}/bin/mktemp" \
      "${pkgs.fontconfig.bin}/bin/fc-cache"

    echo "HM Activation: Berkley Mono install script finished."
  '';

  gtk = {
    enable = true;
    font = {
      name = "Berkeley Mono Variable";
      size = 14;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [fcitx5-hangul];
    };
  };

  home.shell.enableFishIntegration = true;

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = ["Berkeley Mono Variable" "Noto Sans Mono"];

      sansSerif = ["Berkeley Mono Variable" "Noto Sans"];
      serif = ["Berkeley Mono Variable" "Noto Serif"];
    };
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        origin = "bottom-right";
        offset = "48x48";
        scale = 0;
        notification_limit = 5;
        monitor = 1;
        corner_radius = 4;
        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        indicate_hidden = "yes";
        transparency = 16;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        text_icon_padding = 0;
        frame_width = 2;
        frame_collor = "#FFFFFF";
        idle_threshold = 0;
        font = "Berkeley Mono Variable";
        line_height = 0;
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        veritcal_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = true;
        show_indicators = "no";
      };
      urgency_low = {
        background = "#080808";
        foreground = "#f0f0f0";
        frame_color = "#ffffff";
      };
      urgency_normal = {
        background = "#080808";
        foreground = "#f0f0f0";
        frame_color = "#ffffff";
      };
      urgency_critical = {
        background = "#080808";
        foreground = "#db4b4b";
        frame_color = "#db4b4b";
      };
    };
  };

  services.gammastep = {
    enable = true;
    latitude = 40.74833456688329;
    longitude = -73.98545303180413;
    provider = "manual";
    temperature = {
      day = 6500;
      night = 4500;
    };
    settings = {
      general = {
        adjustment-method = "wayland";
        gamma = 0.8;
        fade = 1;
      };
    };
    tray = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;

        options = {
          shiftwidth = 2;
          tabstop = 2;
        };

        keymaps = [
          {
            key =
              if pkgs.stdenv.isDarwin
              then "<D-/>"
              else "<C-/>";
            desc = "Toggle Line Comment";
            mode = "n";
            action = ''
              function()
                vim.api.nvim_feedkeys("gcc", "x", true)
              end
            '';
            lua = true;
          }
          {
            key =
              if pkgs.stdenv.isDarwin
              then "<D-/>"
              else "<C-/>";
            desc = "Toggle Line Comment";
            mode = "v";
            action = ''
              function()
                vim.api.nvim_feedkeys("gb", "v", true)
              end
            '';
            lua = true;
          }
          {
            key = "<leader>e";
            desc = "Toggle Neotree";
            mode = "n";
            action = "<cmd>Neotree toggle reveal<cr>";
          }
        ];

        debugger = {
          nvim-dap = {
            enable = true;
            ui.enable = true;
          };
        };

        comments.comment-nvim = {
          enable = true;
        };

        autocomplete.nvim-cmp.enable = true;

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };

        telescope.enable = true;

        theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
        };

        filetree.neo-tree = {
          enable = true;
          setupOpts = {
            filesystem = {
              filtered_items = {
                visible = true;
              };
            };
          };
        };

        lsp = {
          formatOnSave = true;
        };

        languages = {
          enableLSP = true;
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;
          nix.enable = true;
          ts = {
            enable = true;
            format.type = "biome";
          };
          rust = {
            enable = true;
            crates.enable = true;
          };
        };
      };
    };
  };

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.sessionVariables.NIXOS_ZONE_WL = "1";

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
