{
  pkgs,
  lib,
  config,
  username,
  ...
}: let
  vesktop =
    pkgs.vesktop.overrideAttrs
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
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.symbols-only
  ];

  programs.ghostty = {
    enable = true;
    package =
      if pkgs.stdenv.isLinux
      then pkgs.ghostty
      else null;
    settings = {
      shell-integration-features = "sudo";
      command =
        if pkgs.stdenv.isLinux
        then "fish --login --interactive"
        else null;
      theme = "GruvboxDark";
      font-family = "Berkeley Mono Variable";
      font-style = "Retina";
      font-size = "14";
      gtk-single-instance = "true";
    };
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
