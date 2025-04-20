{pkgs, ...}: {
  home.pointerCursor = {
    enable = true;
    name = "rose-pine-hyprcursor";
    package = pkgs.rose-pine-hyprcursor;
    hyprcursor = {
      enable = true;
      size = 24;
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;

    systemd.variables = ["--all"];
    systemd.enable = false;

    # set to null to use the ones from NixOS module
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
}
