{
  pkgs,
  lib,
  secretsAvailable,
  inputs,
  username,
  ...
}: {
  home.packages = with pkgs; [
    wl-clipboard
    grimblast
    keymapp
    pavucontrol
    protonmail-desktop
    proton-pass
    krita
    typora
    nsxiv
    kitty
    haruna
    handbrake
    cameractrls-gtk4
    winboat
    protonup-ng
    aseprite
  ];

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
        vertical_alignment = "center";
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

  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {cudaSupport = true;};
    plugins = with pkgs.obs-studio-plugins; [wlrobs obs-pipewire-audio-capture];
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  xdg.desktopEntries = {
    "nsxiv" = {
      name = "nsxiv Image Viewer";
      genericName = "Image Viewer";
      comment = "Lightweight and scriptable image viewer";
      exec = "${pkgs.nsxiv}/bin/nsxiv %F";
      icon = "nsxiv";
      terminal = false;
      type = "Application";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      lib.zipAttrsWith
      (_: values: values)
      (let
        subtypes = type: program: subt:
          builtins.listToAttrs (builtins.map
            (x: {
              name = type + "/" + x;
              value = program;
            })
            subt);
      in [
        (subtypes "image" "nsxiv.desktop" ["png" "jpeg" "gif" "svg"])
        (subtypes "x-scheme-handler" "helium-browser.desktop" ["http" "https" "webcal" "about" "unknown"])
        (subtypes "text" "helium-browser.desktop" ["html" "xml"])
        (subtypes "application" "helium-browser.desktop" ["x-extension-htm" "x-extension-html" "x-extension-shtml" "xhtml+xml"])
      ]);
  };

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${username}/.steam/root/compatibilitytools.d";
  };
}
