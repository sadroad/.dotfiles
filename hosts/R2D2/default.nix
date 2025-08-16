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

  nix.settings = {
    experimental-features = ["nix-command" "flakes" "external-builders"];
    external-builders = [
      {
        systems = ["aarch64-linux" "x86_64-linux"];
        program = "/usr/local/bin/determinate-nixd";
        args = ["builder"];
      }
    ];
  };

  networking.hostName = hostname;

  system.stateVersion = 6;

  homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
}
