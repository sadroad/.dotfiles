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
}
