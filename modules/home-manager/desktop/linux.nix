{ inputs, ... }:
let
  wallpaperPrimary = ../../../assets/change.jpg;
  wallpaperSecondary = ../../../assets/1.jpg;
in
{
  imports = [
    ./niri
    ./apps
    ./theme.nix
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    plugins = {
      version = 2;
      sources = [
        {
          enabled = true;
          name = "Official Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = { };
    };
    pluginSettings = { };
    settings = {
      wallpaper = {
        enabled = true;
        overviewEnabled = true;
        setWallpaperOnAllMonitors = false;
        viewMode = "single";
      };
      nightLight = {
        enabled = true;
        autoSchedule = false;
        dayTemp = "6500";
        nightTemp = "4500";
        manualSunrise = "07:30";
        manualSunset = "21:00";
      };
      notifications = {
        enabled = true;
        location = "bottom_right";
        clearDismissed = true;
        saveToHistory = {
          low = true;
          normal = true;
          critical = true;
        };
      };
      colorSchemes = {
        predefinedScheme = "Noctalia (default)";
        useWallpaperColors = false;
      };
      templates = {
        enableUserTheming = false;
      };
      general = {
        lockOnSuspend = true;
      };
      idle = {
        enabled = true;
        screenOffTimeout = 240;
        lockTimeout = 300;
        # suspendTimeout = 1800;
        resumeScreenOffCommand = "niri msg action power-on-monitors";
      };
    };
  };

  home.file.".cache/noctalia/wallpapers.json".text = builtins.toJSON {
    defaultWallpaper = wallpaperPrimary;
    wallpapers = {
      "DP-2" = wallpaperPrimary;
      "DP-3" = wallpaperSecondary;
    };
  };
}
