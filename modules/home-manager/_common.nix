{
  pkgs,
  lib,
  username,
  userDir,
  osConfig,
  ...
}: {
  home.username = username;
  home.homeDirectory = userDir;

  home.sessionVariables = {
    DO_NOT_TRACK = "1";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;

  # Basic packages needed by almost all setups
  home.packages = with pkgs; [
    coreutils
    file
    unzip
    zip
    jq
    wget
    curl
    btop
    man-db
  ];

  programs.tealdeer = {
    enable = true;
    enableAutoUpdates = true;
  };

  nix.settings = {
    access-tokens = "!include ${osConfig.age.secrets."github_oauth".path}";
  };

  programs.home-manager.enable = true;
}
