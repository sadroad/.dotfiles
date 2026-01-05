{ inputs, ... }:
{
  imports = [
    ./system
    ./cli
    ./editors/neovim.nix
    ./editors/zed.nix
    ./editors/helix.nix
    ./desktop

    inputs.nvf.homeManagerModules.default
  ];

  home.stateVersion = "25.11";
}
