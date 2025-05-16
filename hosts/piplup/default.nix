{
  inputs,
  hostname,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
    ./disko-config.nix

    ./configuration.nix
    ./secrets.nix

    ../../modules/nixos/core.nix
    ../../modules/nixos/graphical.nix

    inputs.nvf.nixosModules.default
    inputs.determinate.nixosModules.default
  ];

  networking.hostName = hostname;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["ntfs"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  environment.etc."nix/nix.custom.conf".text = ''
    lazy-trees = true
  '';

  system.stateVersion = "24.11";
}
