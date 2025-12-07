{
  config,
  pkgs,
  lib,
  username,
  userDir,
  secretsAvailable,
  ...
}: {
  nix.settings = {
    accept-flake-config = true;
    access-tokens = lib.mkIf secretsAvailable "!include ${config.age.secrets."github_oauth".path}";
  };

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = ["networkmanager" "wheel" "libvirtd" "docker"];
  };

  programs = {
    ssh.startAgent = true;
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
      ];
    };
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    gamemode.enable = true;
    virt-manager.enable = true;
  };

  services = {
    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };
    resolved.enable = true;
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true; #disable once in clan
      };
      openFirewall = true;
    };
  };

  networking = {
    nameservers = ["192.168.2.1" "100.100.100.100"];
    search = ["tail217ff.ts.net"];
    networkmanager.enable = true;
    nftables.enable = true;
    firewall.enable = true;
  };

  boot = {
    binfmt.emulatedSystems = ["aarch64-linux"];
  };

  security = {
    polkit.enable = true;
    tpm2 = {
      enable = true;
      abrmd.enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
      tctiEnvironment.interface = "tabrmd";
    };
  };

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    ntfs3g

    #steam
    mangohud
  ];

  environment.variables.EDITOR = "nvim";

  users.groups.libvirtd.members = [username];
}
