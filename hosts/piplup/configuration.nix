{
  config,
  pkgs,
  lib,
  inputs,
  username,
  secretsAvailable,
  ...
}: {
  networking = {
    wg-quick.interfaces.wg0 = lib.mkIf secretsAvailable {
      configFile = config.age.secrets."wg-conf".path;
      autostart = false;
    };
    interfaces.enp0s31f6.useDHCP = false;
    networkmanager = {
      settings = {
        main = {
          no-auto-default = "*";
        };
      };
      ensureProfiles.profiles = {
        "physical-enp0s31f6" = {
          connection = {
            id = "physical-enp0s31f6";
            type = "ethernet";
            interface-name = "enp0s31f6";
          };
          ipv4 = {
            method = "disabled";
          };
          ipv6 = {
            method = "disabled";
          };
        };
        "vlan2-profile" = {
          connection = {
            id = "vlan2";
            type = "vlan";
            interface-name = "vlan2";
          };
          vlan = {
            parent = "enp0s31f6";
            id = 2;
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            method = "auto";
          };
        };
      };
    };
  };
}
