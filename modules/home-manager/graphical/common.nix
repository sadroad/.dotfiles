{
  pkgs,
  lib,
  config,
  username,
  hostname,
  ...
}: let
  vesktop = pkgs.callPackage ../custom/vesktop/package.nix {};
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
    qbittorrent
    jetbrains.datagrip

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
      # for claude-code: new line trick
      keybind = "shift+enter=text:\n";
    };
    linuxSettings =
      lib.optionalAttrs pkgs.stdenv.isLinux
      {command = "fish --login --interactive";};
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
