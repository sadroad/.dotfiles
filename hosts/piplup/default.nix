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

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems = ["ntfs"];
    # kernelPackages = pkgs.linuxPackages_cachyos-lto;
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = [];
    trusted-public-keys = [];
    use-xdg-base-directories = true;
  };

  system.stateVersion = "25.11";
}
