{
  pkgs,
  username,
  userDir,
  ...
}:
{
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
      api_key = 0d26e449-9ce8-431c-bd2d-349ced5559ba
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
}
