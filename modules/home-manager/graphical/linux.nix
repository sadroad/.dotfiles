{
  pkgs,
  lib,
  config,
  inputs,
  username,
  ...
}: {
  home.activation.installBerkleyMonoFont = let
    installScript = ../../scripts/install-berkley-mono.sh;
  in
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${installScript} \
        "${pkgs.unzip}/bin/unzip" \
        "${pkgs.coreutils}/bin/mkdir" \
        "${pkgs.coreutils}/bin/cp" \
        "${pkgs.coreutils}/bin/rm" \
        "${pkgs.coreutils}/bin/chmod" \
        "${pkgs.findutils}/bin/find" \
        "${pkgs.coreutils}/bin/mktemp" \
        "${pkgs.fontconfig.bin}/bin/fc-cache" \
    '';

  wayland.windowManager.hyprland = {
    enable = true;

    systemd.variables = ["--all"];
    systemd.enable = false;

    package = null;
    portalPackage = null;

    settings = {
      "$mainMod" = "SUPER";

      monitor = ["DP-3, 2560x1440@180,0x0,1" "DP-1, 1920x1080@165,0x-1080,1"];

      "$menu" = "bemenu-run -b";
      "$terminal" = "ghostty";
      "$screenshot" = "grimblast --freeze copy area";

      # hack to make main monitor have inital focus
      workspace = "name:1, monitor:DP-3";

      exec-once = [
        "hyprctl dispatch workspace 1"
        "[workspace 1 silent] $terminal"
      ];

      general = {
        gaps_in = "5";
        gaps_out = "5";
        border_size = "0";
        resize_on_border = "false";
        allow_tearing = "false";
        layout = "dwindle";
      };

      decoration = {
        rounding = "10";
        active_opacity = "1.0";
        inactive_opacity = "1.0";

        shadow = {
          enabled = "true";
          range = "4";
          render_power = "3";
          color = "rgba(1a1a1aee)";
        };

        blur = {
          enabled = "true";
          size = "3";
          passes = "1";

          vibrancy = "0.1696";
        };
      };

      animations.enabled = "false";

      dwindle = {
        pseudotile = "true";
        preserve_split = "true";
      };

      misc = {
        force_default_wallpaper = "-1";
        disable_hyprland_logo = "false";
        vrr = "1";
      };

      input = {
        kb_layout = "us";
        follow_mouse = "1";
        accel_profile = "flat";
      };

      windowrulev2 = [
        "float,class:git-butler"
        "float,class:org.pulseaudio.pavucontrol"
        "suppressevent maximize, class:.*"
      ];

      bind =
        [
          "$mainMod, R, exec, $menu"
          "$mainMod, Q, exec, $terminal"
          "$mainMod, C, killactive,"
          "$mainMod, M, exit,"
          "$mainMod, V, togglefloating,"
          "$mainMod, P, pseudo, "
          "$mainMod, J, togglesplit, "
          "$mainMod CTRL, S, exec, $screenshot"

          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod SHIFT, S, movetoworkspace, special:magic"
        ]
        ++ (
          #workspaces
          # binds $mainMod + [shift +] {1..9} to workspaces {1..9}
          builtins.concatLists (builtins.genList (
              i: let
                ws = i + 1;
              in [
                "$mainMod, ${toString ws}, workspace, ${toString ws}"
                "$mainMod SHIFT, ${toString ws}, movetoworkspace, ${toString ws}"
              ]
            )
            9)
        );

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ./waybar/style.css;
    settings = {
      mainBar = {
        height = 24;
        modules-left = ["hyprland/workspaces" "hyprland/submap"];
        modules-right = ["network" "pulseaudio" "tray" "clock"];
        "hyprland/submap" = {
          format = "<span style=\"italic\">{}</span>";
        };
        tray = {
          spacing = 10;
        };
        clock = {
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format = "{:L%Y-%m-%d<small>[%a]</small> <tt><small>%p</small></tt>%I:%M}";
        };
        pulseaudio = {
          scroll-step = 5;
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = " {icon} {volume}% {format_source}";
          format-bluetooth-muted = "  {icon} {format_source}";
          format-muted = "  {format_source}";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
          on-click-right = "foot -a pw-top pw-top";
        };
      };
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

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "off";
      preload = [
        "${config.age.secrets."1.jpg".path}"
        "${config.age.secrets."change.jpg".path}"
      ];
      wallpaper = [
        "DP-3, ${config.age.secrets."change.jpg".path}"
        "DP-1, ${config.age.secrets."1.jpg".path}"
      ];
    };
  };

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [fcitx5-hangul];
    };
  };

  home.pointerCursor = {
    enable = true;
    name = "BreezeX-RosePine-Linux";
    package = pkgs.rose-pine-cursor;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.packages = with pkgs; [
    bemenu
    wl-clipboard
    grimblast
    keymapp
    pavucontrol
  ];

  home.sessionVariables = {
    NIXOS_ZONE_WL = "1";
  };

  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {
      cudaSupport = true;
    };
    plugins = with pkgs.obs-studio-plugins; [wlrobs obs-pipewire-audio-capture];
  };
}
