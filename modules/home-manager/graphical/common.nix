{
  pkgs,
  lib,
  config,
  username,
  ...
}: let
  custom-vesktop = pkgs.callPackage ../custom/vesktop/package.nix {};

  vesktop =
    custom-vesktop.overrideAttrs
    (oldAttrs: {
      postPatch = ''
        mkdir -p static #ensuring that the folder exists
        rm -f static/shiggy.gif
        cp ${../../../assets/shiggy.gif} static/shiggy.gif
      '';
    });
in {
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = ["Berkeley Mono Variable" "Noto Sans Mono"];

      sansSerif = ["Berkeley Mono Variable" "Noto Sans"];
      serif = ["Berkeley Mono Variable" "Noto Serif"];
    };
  };

  home.packages = with pkgs; [
    brave
    vesktop
    spotify
    zed-editor
    qbittorrent

    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.symbols-only
  ];

  programs.ghostty = let
    baseSettings = {
      shell-integration-features = "sudo";
      theme = "GruvboxDark";
      font-family = "Berkeley Mono Variable";
      font-style = "Retina";
      font-size = "14";
      gtk-single-instance = "true";
    };
    linuxSettings =
      if pkgs.stdenv.isLinux
      then {command = "fish --login --interactive";}
      else {};
  in {
    enable = true;
    package =
      if pkgs.stdenv.isLinux
      then pkgs.ghostty
      else null;
    settings = baseSettings // linuxSettings;
  };

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
}
