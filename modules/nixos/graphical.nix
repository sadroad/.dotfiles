{
  config,
  pkgs,
  lib,
  username,
  inputs,
  ...
}: {
  programs.hyprland = lib.mkIf (inputs ? hyprland) {
    enable = true;
    withUWSM = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  services.displayManager.sddm = {
    enable = true;
  };

  services.xserver = {
    enable = true;
    videoDrivers = ["nvidia"];
  };

  hardware.nvidia = {
    open = true;
    nvidiaSettings = true;
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = false;
    };

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver
      nvidia-vaapi-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva
    ];
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
  };
  users.users.${username}.extraGroups = ["audio" "video"];

  # obs virtual cam
  boot.kernelModules = ["v4l2loopback"];
  boot.extraModulePackages = [config.boot.kernelPackages.v4l2loopback];
  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"

  '';

  security.pam.services.hyprlock = {};

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  hardware.keyboard.zsa.enable = true;
}
