{
  pkgs,
  lib,
  config,
  username,
  ...
}: {
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
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome
    (nerdfonts.override {fonts = ["SymbolsOnly" "JetBrainsMono"];})
  ];

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
