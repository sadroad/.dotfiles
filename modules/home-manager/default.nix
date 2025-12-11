{inputs, ...}: {
  imports = [
    ./system
    ./cli
    ./editors/neovim.nix
    ./editors/zed.nix
    ./desktop

    inputs.nvf.homeManagerModules.default
  ];

  home.stateVersion = "25.11";
}
