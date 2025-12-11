{
  inputs,
  hostname,
  ...
}: {
  imports = [
    ./configuration.nix
    ./secrets.nix
    ./disko-config.nix

    ../../modules/nixos/core.nix
    ../../modules/nixos/graphical.nix

    inputs.nixos-facter-modules.nixosModules.facter
    {config.facter.reportPath = ./facter.json;}
    inputs.disko.nixosModules.disko
    inputs.nvf.nixosModules.default
  ];

  networking.hostName = hostname;

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems = ["ntfs"];
    # not building currently
    #kernelPackages = pkgs.linuxPackages_cachyos-lto;
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = [];
    trusted-public-keys = [];
    use-xdg-base-directories = true;
  };

  system.stateVersion = "25.11";
}
