{
  inputs,
  hostname,
  pkgs,
  lib,
  ...
}: {
  imports =
    [
      ./hardware-configuration.nix
      ./configuration.nix
      ./secrets.nix

      ../../modules/nixos/core.nix
      ../../modules/nixos/graphical.nix
    ]
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
    )
    ++ (
      lib.optionals (inputs ? chaotic) [
        inputs.chaotic.nixosModules.default
      ]
    );

  networking.hostName = hostname;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["ntfs"];
  boot.kernelPackages = pkgs.linuxPackages_cachyos-lto;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  system.stateVersion = "24.11";
}
