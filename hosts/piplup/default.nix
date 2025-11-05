{
  inputs,
  hostname,
  pkgs,
  lib,
  ...
}: {
  imports =
    [
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
    );

  networking.hostName = hostname;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["ntfs"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  system.stateVersion = "24.11";
}
