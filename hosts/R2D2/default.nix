{
  inputs,
  config,
  hostname,
  lib,
  ...
}: {
  imports =
    [
      ./configuration.nix
      ./secrets.nix

      ../../modules/darwin/core.nix
    ]
    ++ (
      lib.optionals (inputs ? mac-app-util) [
        inputs.mac-app-util.darwinModules.default
      ]
    );
  nix.enable = false; #required by determinate-nix

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  networking.hostName = hostname;

  system.stateVersion = 6;

  homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
}
