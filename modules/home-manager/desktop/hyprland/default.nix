_: {
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.variables = [ "--all" ];
    systemd.enable = false;
    package = null;
    portalPackage = null;
    settings = {
      "$mainMod" = "SUPER";
      monitor = [
        "DP-2, 2560x1440@180,0x0,1"
        "DP-3, 1920x1080@165,-1920x0,1"
        "HDMI-A-1, preferred, auto, 1, mirror, DP-2"
      ];
      "$menu" = "hyprlauncher";
      "$terminal" = "ghostty";
      "$screenshot" = "grimblast --freeze copy area";
      workspace = "name:1, monitor:DP-2";
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
      windowrule = [
        "match:class org.pulseaudio.pavucontrol, float on"
        "match:class .*, suppress_event maximize"
        "match:class ^(Proton Pass|proton-pass)$, no_screen_share on"
      ];
    };
  };

  imports = [
    ./binds.nix
    ./services.nix
  ];
}
