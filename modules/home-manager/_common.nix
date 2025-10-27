{
  pkgs,
  lib,
  username,
  userDir,
  osConfig,
  secretsAvailable,
  ...
}: {
  home.username = username;
  home.homeDirectory = userDir;

  home.sessionVariables = {
    DO_NOT_TRACK = "1";
  };

  home.file.".wakatime.cfg".text = ''
    [settings]
    api_url = https://wakapi.local.villablanca.tech/api
    api_key = 0b912f80-7a56-4f0a-8c3d-55573fcda2bd
  '';

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

  nix.settings = lib.mkIf secretsAvailable {
    access-tokens = "!include ${osConfig.age.secrets."github_oauth".path}";
  };

  programs.home-manager.enable = true;
}
