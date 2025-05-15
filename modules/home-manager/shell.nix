{
  pkgs,
  lib,
  config,
  ...
}: {
  home.shell.enableFishIntegration = true;

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "pure";
        inherit (pkgs.fishPlugins.pure) src;
      }
    ];
    functions = {
      y = ''
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
      '';
    };
    shellAbbrs = {
      reload = "source ~/.config/fish/config.fish";
      mkdir = "mkdir -p";
      type = "type -a";
    };
    shellAliases = {
      ls = "eza";
      l = "eza -lah";
      cat = "bat";
      grep = "rg";
      tree = "eza --tree";
      top = "btop";
      du = "dust";
      xxd = "hexyl";
      find = "fd";
      cd = "z";
      dig = "doggo";
      ps = "procs";
      ping = "gping";
      diff = "delta";
      gzip = "pigz";
      "rec" = "asciinema rec -c fish";
    };
  };

  programs.atuin = {
    daemon.enable = true;
    enable = true;
    flags = ["--disable-up-arrow"];
    settings = {
      sync_address = "https://atuin.local.villablanca.tech";
      enter_accept = false;
      sync = {
        records = true;
      };
      dotfiles.enable = false;
    };
  };

  programs.zoxide = {
    enable = true;
  };

  home.sessionVariables = {
    PAGER = "delta";
    MANPAGER = ''sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman' '';
    fish_greeting = "";
    pure_enable_nixdevshell = "true";
  };
}
