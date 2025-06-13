{
  pkgs,
  lib,
  config,
  ...
}: let
  gitName = "Alex Villablanca";
  gitEmail = "alex@villablanca.tech";
  gitSigningKey = "2B826E3C035C8BB5";
in {
  home.packages = with pkgs; [
    git-secrets
    mergiraf
  ];
  programs.git = {
    enable = true;
    userEmail = gitEmail;
    userName = gitName;
    delta = {
      enable = true;
      options = {
        navigate = true;
      };
    };
    attributes = ["* merge=mergiraf"];
    extraConfig = {
      rerere = {
        enable = true;
      };
      merge = {
        conflictstyle = "diff3";
      };
      "merge \"mergiraf\"" = {
        name = "mergiraf";
        driver = "mergiraf merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
      };
      diff = {
        colorMoved = "default";
      };
      color = {
        ui = true;
      };
    };
    signing = {
      key = gitSigningKey;
      format = "openpgp";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      ui = {
        pager = "delta";
        merge-editor = "mergiraf";
      };
      user = {
        name = gitName;
        email = gitEmail;
      };
      git = {
        sign-on-push = true;
      };
      signing = {
        behavior = "drop";
        key = gitSigningKey;
        backend = "gpg";
      };
    };
  };
}
