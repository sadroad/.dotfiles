{
  config,
  pkgs,
  lib,
  username,
  inputs,
  ...
}: {
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = username;
    autoMigrate = true;

    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
    };
    mutableTaps = false;

    brews = [
    ];
    casks = [
      "orbstack"
      "ghostty"
      "iina"
      "raycast"
      "alt-tab"
      "imhex"
      "gpg-suite-no-mail"
    ];

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
  };
}
