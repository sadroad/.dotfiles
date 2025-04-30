{
  config,
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];

  programs.fish.enable = true;

  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
  };

  security.pam.enableSudoTouchIdAuth = true;

  location.provider = "corelocation";
}
