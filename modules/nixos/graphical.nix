{
  config,
  pkgs,
  lib,
  username,
  inputs,
  ...
}: let
  sddm-eucalyptus-drop = pkgs.callPackage ./sddm-theme.nix {inherit config;};
in {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  services.displayManager.sddm = {
    enable = true;
    theme = "eucalyptus-drop";
  };

  services.xserver = {
    enable = true;
    videoDrivers = ["nvidia"];
  };

  hardware.nvidia = {
    open = true;
    nvidiaSettings = true;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      nvidia-vaapi-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva
    ];
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  users.users.${username}.extraGroups = ["audio"];

  hardware.keyboard.zsa.enable = true;

  environment.systemPackages = with pkgs; [
    sddm-eucalyptus-drop
    libsForQt5.qt5.qtgraphicaleffects # required for sddm-eucalyptus-drop

    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    pkgs.nerd-fonts.jetbrains-mono
  ];
}
