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
    api_key = 58e0d4e5-6cc9-497f-942b-2ad88186466a
  '';

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;

  home.packages = with pkgs; [
    coreutils
    file
    unzip
    zip
    jq
    wget
    curl
    man-db
  ];

  programs.btop = {
    enable = true;
  };

  programs.tealdeer = {
    enable = true;
    enableAutoUpdates = true;
  };

  nix.settings = lib.mkIf secretsAvailable {
    access-tokens = "!include ${osConfig.age.secrets."github_oauth".path}";
  };

  programs.home-manager.enable = true;
}
