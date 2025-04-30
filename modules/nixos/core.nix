{
  config,
  pkgs,
  username,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = ["networkmanager" "wheel" "libvirtd"];
  };

  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    openFirewall = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    ntfs3g
  ];

  programs.fish.enable = true;

  environment.variables.EDITOR = "nvim";

  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [username];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
