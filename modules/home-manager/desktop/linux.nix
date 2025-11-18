{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hyprland
    ./waybar
    ./apps
    ./theme.nix
  ];
}
