{
  config,
  pkgs,
  lib,
  username,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = ["networkmanager" "wheel" "libvirtd"]; # Add groups needed on Linux
  };

  networking.networkmanager.enable = true;

  # Timezone
  time.timeZone = "America/New_York";

  # SSH Server
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    openFirewall = true;
  };

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Base packages needed on NixOS system
  environment.systemPackages = with pkgs; [
    git # Git might be needed early by some system services
    ntfs3g # Moved from configuration.nix
    # Add other essential system-level tools for NixOS
    wget
    curl
  ];

  # Enable the Flakes feature and nix command
  nix.settings.experimental-features = ["nix-command" "flakes"];
  programs.fish.enable = true; # Enable fish shell globally

  # Intel microcode updates
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Kernel Modules
  boot.initrd.availableKernelModules = ["vmd" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  # Basic environment variables
  environment.variables.EDITOR = "nvim"; # Good default
}
