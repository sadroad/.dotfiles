{
  config,
  pkgs,
  lib,
  inputs,
  username,
  ...
}: {
  imports = [
    ./system
    ./cli
    ./editors/neovim.nix
    ./editors/zed.nix
    ./desktop

    inputs.nvf.homeManagerModules.default
    inputs.walker.homeManagerModules.default
  ];

  home.stateVersion = "24.11";
}
