{
  pkgs,
  lib,
  inputs,
  config,
  username,
  hostname,
  ...
}: let
  ghostty =
    if inputs ? ghostty && pkgs.stdenv.isLinux
    then inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
    else pkgs.ghostty-bin;
in {
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = ["Berkeley Mono Variable" "Noto Sans Mono"];

      sansSerif = ["Berkeley Mono Variable" "Noto Sans"];
      serif = ["Berkeley Mono Variable" "Noto Serif"];
    };
  };

  home.packages = with pkgs;
    [
      brave
      vesktop
      spotify
      qbittorrent

      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      font-awesome
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.nerd-fonts.symbols-only
      prismlauncher
      hoppscotch
      imhex
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      grandperspective
      iina
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
      lib.optionalAttrs pkgs.stdenv.isLinux
      {
        command = "fish --login --interactive";
      };
  in {
    enable = true;
    package = ghostty;
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
