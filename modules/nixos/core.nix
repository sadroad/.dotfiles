{
  config,
  pkgs,
  username,
  userDir,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = ["networkmanager" "wheel" "libvirtd"];
  };

  networking.networkmanager.enable = true;

  networking.nftables.enable = true;

  networking.firewall.enable = true;

  time.timeZone = "America/New_York";

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true; #disable once in clan
    };
    openFirewall = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    ntfs3g

    #steam
    mangohud
  ];

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  environment.variables.EDITOR = "nvim";

  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [username];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
