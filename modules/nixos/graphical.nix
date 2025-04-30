{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  services.displayManager.sddm.enable = true;

  services.xserver = {
    enable = true;
    videoDrivers = ["nvidia"];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

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
  users.users.${config.users.users.sadroad.name}.extraGroups = ["audio"];

  hardware.keyboard.zsa.enable = true;

  environment.systemPackages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    (nerdfonts.override {fonts = ["JetBrainsMono"];})
  ];

  # Policy for Brave (keep if desired)
  environment.etc."brave/policies/managed/policies.json" = {
    source = ../../assets/policies.json; # Assuming you move policies.json to assets
    mode = "0444";
  };
}
