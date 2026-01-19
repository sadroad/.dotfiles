{
  config,
  pkgs,
  lib,
  inputs,
  username,
  secretsAvailable,
  ...
}:
let
  inherit (lib)
    filterAttrs
    isType
    mapAttrs
    mapAttrsToList
    ;
  registryMap = filterAttrs (_: v: isType v "flake") inputs;
in
{
  nix.settings = {
    accept-flake-config = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    http-connections = 50;
    builders-use-substitutes = true;
    flake-registry = "";
    show-trace = true;
    warn-dirty = false;
  }
  // lib.optionalAttrs secretsAvailable {
    access-tokens = "!include ${config.age.secrets."github_oauth".path}";
  };

  nix.optimise.automatic = true;

  nix.nixPath = mapAttrsToList (name: value: "${name}=${value}") registryMap;

  nix.registry = mapAttrs (_: flake: { inherit flake; }) (
    registryMap // { default = inputs.nixpkgs; }
  );

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
    persistent = true;
  };

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "docker"
    ];
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
      extraSetFlags = [ "--ssh" ];
    };
    resolved.enable = true;
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true; # disable once in clan
      };
      openFirewall = true;
    };
    fwupd.enable = true;
  };

  networking = {
    nameservers = [
      "192.168.2.1"
      "100.100.100.100"
    ];
    search = [ "tail217ff.ts.net" ];
    networkmanager.enable = true;
    nftables.enable = true;
    firewall.enable = true;
  };

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
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

    mangohud
  ];

  environment.variables.EDITOR = "hx";

  users.groups.libvirtd.members = [ username ];
}
