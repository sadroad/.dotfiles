{
  config,
  pkgs,
  lib,
  inputs,
  username,
  secretsAvailable,
  ...
}: {
  networking.wg-quick.interfaces.wg0 = lib.mkIf secretsAvailable {
    configFile = config.age.secrets."wg-conf".path;
    autostart = false;
  };
}
