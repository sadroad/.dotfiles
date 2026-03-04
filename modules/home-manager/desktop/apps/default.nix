{
  pkgs,
  lib,
  username,
  inputs,
  ...
}:
let
  handy = inputs.handy.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home.packages = with pkgs; [
    wl-clipboard
    grimblast
    grim
    slurp
    keymapp
    pavucontrol
    protonmail-desktop
    proton-pass
    krita
    typora
    nsxiv
    kitty
    haruna
    cameractrls-gtk4
    winboat
    protonup-ng
    hyprpicker
    # calibre
    handy
  ];

  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override { cudaSupport = true; };
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
    ];
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
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
    defaultApplications = lib.zipAttrsWith (_: values: values) (
      let
        subtypes =
          type: program: subt:
          builtins.listToAttrs (
            builtins.map (x: {
              name = type + "/" + x;
              value = program;
            }) subt
          );
      in
      [
        (subtypes "image" "nsxiv.desktop" [
          "png"
          "jpeg"
          "gif"
          "svg"
        ])
        (subtypes "x-scheme-handler" "helium-browser.desktop" [
          "http"
          "https"
          "webcal"
          "about"
          "unknown"
        ])
        (subtypes "text" "helium-browser.desktop" [
          "html"
          "xml"
        ])
        (subtypes "application" "helium-browser.desktop" [
          "x-extension-htm"
          "x-extension-html"
          "x-extension-shtml"
          "xhtml+xml"
        ])
        (subtypes "application" "org.pwmt.zathura.desktop" [
          "pdf"
          "postscript"
        ])
      ]
    );
  };

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${username}/.steam/root/compatibilitytools.d";
  };
}
