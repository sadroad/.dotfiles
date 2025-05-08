{
  config,
  pkgs,
  lib,
  inputs,
  username,
  ...
}: {
  # just to remove brave bloat
  environment.etc."brave/policies/managed/policies.json" = {
    source = ../../assets/policies.json;
    mode = "0444";
    user = "root";
    group = "root";
  };

  programs.ssh.startAgent = true;

  networking.wg-quick.interfaces.wg0 = {
    configFile = config.age.secrets."wg-conf".path;
    autostart = false;
  };

  # obs virutal cam
  boot.kernelModules = ["v4l2loopback"];
  boot.extraModulePackages = [config.boot.kernelPackages.v4l2loopback];
  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"

  '';

  security.polkit.enable = true;

  virtualisation.docker.enable = true;

  users.users.${username}.extraGroups = ["video" "docker"];
}
