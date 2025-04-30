{
  pkgs,
  lib,
  config,
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

    # Graphical elements (common and OS-specific)
    ./graphical/common.nix
    ./os-specific.nix

    inputs.nvf.homeManagerModules.default
  ];

  home.stateVersion = "24.11";
}
