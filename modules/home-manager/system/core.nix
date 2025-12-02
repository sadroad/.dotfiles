{
  pkgs,
  lib,
  username,
  userDir,
  osConfig,
  secretsAvailable,
  ...
}: {
  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';

  home = {
    inherit username;
    homeDirectory = userDir;
    sessionVariables = {
      DO_NOT_TRACK = "1";
    };
    file.".wakatime.cfg".text = ''
      [settings]
      api_url = https://wakapi.local.villablanca.tech/api
      api_key = 58e0d4e5-6cc9-497f-942b-2ad88186466a
    '';
    packages = with pkgs; [
      coreutils
      file
      unzip
      zip
      jq
      man-db
    ];
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    nix-index.enable = true;
    btop = {
      enable = true;
    };
    tealdeer = {
      enable = true;
      enableAutoUpdates = true;
    };
    home-manager.enable = true;
  };

  nix.settings = lib.mkIf secretsAvailable {
    access-tokens = "!include ${osConfig.age.secrets."github_oauth".path}";
  };
}
