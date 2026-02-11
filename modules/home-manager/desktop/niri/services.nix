{ pkgs, ... }:
let
  wallpaperChange = pkgs.copyPathToStore ../../../../assets/change.jpg;
  wallpaper1 = pkgs.copyPathToStore ../../../../assets/1.jpg;
in
{
  services.polkit-gnome.enable = true;

  home.packages = with pkgs; [
    swww
    wlsunset
    wl-mirror
    fuzzel
    nautilus # Required for xdg-desktop-portal-gnome file chooser (v47.0+)
  ];

  programs.niri.settings.spawn-at-startup = [
    # Wallpaper daemon and images
    { command = [ "${pkgs.swww}/bin/swww-daemon" ]; }
    {
      command = [
        "${pkgs.swww}/bin/swww"
        "img"
        "--outputs"
        "DP-2"
        "${wallpaperChange}"
      ];
    }
    {
      command = [
        "${pkgs.swww}/bin/swww"
        "img"
        "--outputs"
        "DP-3"
        "${wallpaper1}"
      ];
    }
    # Night light (4500K-6500K)
    {
      command = [
        "${pkgs.wlsunset}/bin/wlsunset"
        "-T"
        "6500"
        "-t"
        "4500"
        "-S"
        "07:30"
        "-s"
        "21:00"
      ];
    }
  ];

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "niri msg action power-on-monitors";
        lock_cmd = "pidof hyprlock || hyprlock";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
      ];
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
          path = "${wallpaperChange}";
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
