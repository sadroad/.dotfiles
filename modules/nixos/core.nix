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
    extraGroups = ["networkmanager" "wheel" "libvirtd" "docker"];
  };

  programs.ssh.startAgent = true;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  networking.nameservers = ["192.168.2.1" "100.100.100.100"];
  networking.search = ["tail217ff.ts.net"];

  services.resolved.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
    ];
  };

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  security.polkit.enable = true;

  security.tpm2 = {
    enable = true;
    abrmd.enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
    tctiEnvironment.interface = "tabrmd";
  };

  virtualisation.docker.enable = true;

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
    curl
    wget
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
