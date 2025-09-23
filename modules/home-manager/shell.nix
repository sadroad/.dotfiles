{
  pkgs,
  lib,
  config,
  ...
}: {
  home.shell.enableNushellIntegration = true;

  programs.nushell = {
    enable = true;
    extraConfig = ''
      def mkcd [dir_name?: string] {
          if $dir_name == null {
              print "Usage: mkcd <directory_name>"
              return 1
          }

          mkdir $dir_name

          if $env.LAST_EXIT_CODE == 0 {
              cd $dir_name
          } else {
              print $"Error: Could not create directory '($dir_name)'."
              return $env.LAST_EXIT_CODE
          }
      }
    '';

    settings = {
      show_banner = false;
    };

    shellAliases =
      {
        l = "ls -lat";
        cat = "bat";
        grep = "rg";
        tree = "eza --tree";
        top = "btop";
        xxd = "hexyl";
        cd = "z";
        dig = "doggo";
        diff = "delta";
        gzip = "pigz";
        "rec" = "asciinema rec -c nu";
        zed = "zeditor";
        pkg-build = "nix-build -E \"with import <nixpkgs> {}; callPackage ./package.nix {}\"";
        type = "type -a";
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        dns-down = "sudo -v and tailscale down and sudo networksetup -setdnsservers \"Wi-Fi\" empty and sudo killall -HUP mDNSResponder";
        dns-up = "sudo -v and tailscale up and sudo networksetup -setdnsservers \"Wi-Fi\" 1.1.1.1 1.0.0.1 9.9.9.9 and sudo killall -HUP mDNSResponder";
        dns-reset = "dns-down and dns-up";
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

  programs.carapace.enable = true;

  home.sessionVariables = {
    PAGER = "delta";
    MANPAGER = ''sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman' '';
    pure_enable_nixdevshell = "true";
  };
}
