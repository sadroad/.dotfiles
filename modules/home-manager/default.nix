{
  config,
  pkgs,
  lib,
  inputs,
  username,
  ...
}: {
  imports = [
    # Core HM settings
    ./_common.nix

    # Feature modules
    ./cli.nix
    ./shell.nix
    ./git.nix
    ./gpg.nix
    ./editors/neovim.nix
    ./editors/zed.nix

    # Graphical elements (common and OS-specific)
    ./graphical/common.nix
    ./os-specific.nix

    inputs.nvf.homeManagerModules.default
    inputs.walker.homeManagerModules.default
  ];

  home.stateVersion = "24.11";
}
