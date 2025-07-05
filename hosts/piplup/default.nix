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
    inputs.chaotic.nixosModules.default
  ];

  networking.hostName = hostname;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["ntfs"];
  boot.kernelPackages = pkgs.linuxPackages_cachyos-lto;
  #boot.kernelPackages = pkgs.linuxPackages_6_14;

  services.scx.enable = true;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  system.stateVersion = "24.11";
}
