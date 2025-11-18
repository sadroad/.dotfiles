{
  config,
  pkgs,
  lib,
  inputs,
  username,
  secretsAvailable,
  ...
}: {
  programs.ssh.startAgent = true;

  networking.wg-quick.interfaces.wg0 = lib.mkIf secretsAvailable {
    configFile = config.age.secrets."wg-conf".path;
    autostart = false;
  };

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

  # obs virtual cam
  boot.kernelModules = ["v4l2loopback"];
  boot.extraModulePackages = [config.boot.kernelPackages.v4l2loopback];
  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"

  '';

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  security.polkit.enable = true;

  security.pam.services.hyprlock = {};

  security.tpm2 = {
    enable = true;
    abrmd.enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
    tctiEnvironment.interface = "tabrmd";
  };

  virtualisation.docker.enable = true;

  users.users.${username}.extraGroups = ["video" "docker"];
}
