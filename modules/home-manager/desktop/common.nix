{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  ghostty =
    if pkgs.stdenv.isLinux then
      inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
    else
      pkgs.ghostty-bin;
in
{
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [
        "Berkeley Mono Variable"
        "Noto Sans Mono"
      ];

      sansSerif = [
        "Berkeley Mono Variable"
        "Noto Sans"
      ];
      serif = [
        "Berkeley Mono Variable"
        "Noto Serif"
      ];
    };
  };

  home.packages =
    with pkgs;
    [
      vesktop
      spotify
      qbittorrent

      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      font-awesome
      corefonts
      vista-fonts
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.nerd-fonts.symbols-only
      prismlauncher
      # imhex
      slack
      helium
      yaak
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      grandperspective
      iina
      localsend # on nixos enabled through service
      orbstack
    ];
  programs.ghostty =
    let
      baseSettings = {
        shell-integration-features = "sudo, ssh-terminfo";
        theme = "Gruvbox Dark";
        font-family = "Berkeley Mono Variable";
        font-style = "Retina";
        font-size = "14";
        gtk-single-instance = "true";
      };
      linuxSettings = lib.optionalAttrs pkgs.stdenv.isLinux {
        command = "${pkgs.nushell}/bin/nu --login --interactive";
      };
    in
    {
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

  programs.zathura = {
    enable = true;
  };
}
