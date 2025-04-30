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
    extraConfig = {
      rerere = {
        enable = true;
      };
      merge = {
        conflictstyle = "diff3";
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
      };
      user = {
        name = gitName;
        email = gitEmail;
      };
      git = {
        subprocess = true;
        sign-on-push = true;
      };
      signing = {
        behavoir = "drop";
        key = gitSigningKey;
        backend = "gpg";
      };
    };
  };
}
