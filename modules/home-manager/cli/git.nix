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
  programs.difftastic = {
    enable = true;
    git = {
      enable = true;
      diffToolMode = true;
    };
  };

  programs.delta = {
    enable = true;
    options = {
      navigate = true;
    };
  };

  programs.mergiraf = {
    enable = true;
  };

  programs.git = {
    enable = true;
    attributes = ["* merge=mergiraf"];
    settings = {
      user = {
        email = gitEmail;
        name = gitName;
      };
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
        diff-formatter = ["difft" "--color=always" "$left" "$right"];
        merge-editor = "mergiraf";
      };
      user = {
        name = gitName;
        email = gitEmail;
      };
      git = {
        sign-on-push = true;
        colocate = true;
      };
      signing = {
        behavior = "drop";
        key = gitSigningKey;
        backend = "gpg";
      };
    };
  };
}
