{
  inputs,
  hostname,
  pkgs,
  lib,
  ...
}: {
  imports =
    [
      # ./hardware-configuration.nix
      ./configuration.nix
      ./secrets.nix

      ../../modules/nixos/core.nix
      ../../modules/nixos/graphical.nix
    ]
    ++ (
      lib.optionals (inputs ? nixos-facter-modules) [
        inputs.nixos-facter-modules.nixosModules.facter
        {config.facter.reportPath = ./facter.json;}
      ]
    )
    ++ (
      lib.optionals (inputs ? disko) [
        inputs.disko.nixosModules.disko
        ./disko-config.nix
      ]
    )
    ++ (
      lib.optionals (inputs ? nvf) [
        inputs.nvf.nixosModules.default
      ]
    )
    ++ (
      lib.optionals (inputs ? determinate) [
        inputs.determinate.nixosModules.default
      ]
    );

  networking.hostName = hostname;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["ntfs"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = ["https://cache.flox.dev" "https://hyprland.cachix.org"];
    trusted-public-keys = ["flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs=" "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  system.stateVersion = "24.11";
}
