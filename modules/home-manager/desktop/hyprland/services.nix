{
  pkgs,
  lib,
  secretsAvailable,
  ...
}: {
  services = {
    hyprsunset = {
      enable = true;
      settings = {
        max-gamma = 150;
        profile = [
          {
            time = "07:30";
            identity = true;
          }
          {
            time = "21:00";
            temperature = 4500;
            gamma = 0.7;
          }
        ];
      };
    };
    hyprpaper = {
      enable = true;
      settings = let
        wallpaper1 = pkgs.copyPathToStore ../../../../assets/1.jpg;
        wallpaperChange = pkgs.copyPathToStore ../../../../assets/change.jpg;
      in {
        ipc = "on";
        preload = [wallpaper1 wallpaperChange];
        wallpaper = ["DP-2, ${wallpaperChange}" "DP-3, ${wallpaper1}"];
      };
    };
    hyprpolkitagent.enable = true;
    hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          lock_cmd = "pidof hyprlock || hyprlock";
        };
        listener = [
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 330;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };
      animations = {
        enabled = true;
        fade_in = {
          duration = 300;
          bezier = "easeOutQuint";
        };
        fade_out = {
          duration = 300;
          bezier = "easeOutQuint";
        };
      };
      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "...";
          shadow_passes = 2;
        }
      ];
    };
  };
}
