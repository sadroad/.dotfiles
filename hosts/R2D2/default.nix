{
  inputs,
  config,
  hostname,
  ...
}: {
  imports = [
    ./configuration.nix
    ./secrets.nix

    ../../modules/darwin/core.nix
    ../../modules/darwin/homebrew.nix

    inputs.mac-app-util.darwinModules.default
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];
  nix.enable = false;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = hostname;

  system.stateVersion = 6;

  homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
}
