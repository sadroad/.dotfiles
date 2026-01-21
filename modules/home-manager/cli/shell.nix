{
  pkgs,
  lib,
  config,
  ...
}:
let
  manpager = pkgs.writeShellScriptBin "manpager" ''
    awk '{ gsub(/\x1B\[[0-9;]*m/, "", $0); gsub(/.\x08/, "", $0); print }' | ${pkgs.bat}/bin/bat -p -lman
  '';
in
{
  home.shell.enableNushellIntegration = true;

  programs = {
    nushell = {
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
      ''
      + lib.optionalString pkgs.stdenv.isDarwin ''
        def dns-down [] {
            sudo -v
            tailscale down
            sudo networksetup -setdnsservers "Wi-Fi" empty
            sudo killall -HUP mDNSResponder
        }

        def dns-up [] {
            sudo -v
            tailscale up
            sudo networksetup -setdnsservers "Wi-Fi" 1.1.1.1 1.0.0.1 9.9.9.9
            sudo killall -HUP mDNSResponder
        }

        def dns-reset [] {
            dns-down
            dns-up
        }
      '';

      settings = {
        show_banner = false;
      };
      extraEnv =
        let
          exportToNuEnv =
            vars:
            lib.concatStringsSep "\n" (lib.mapAttrsToList (n: v: "$env.${n} = ${builtins.toJSON v}") vars);
        in
        lib.mkBefore (
          ''
            ${exportToNuEnv config.home.sessionVariables}
          ''
          + lib.optionalString (config.home.sessionPath != [ ]) ''
            $env.PATH = $env.PATH | split row ':' | prepend [
              ${lib.concatStringsSep " " config.home.sessionPath}
            ]
          ''
        );

      shellAliases = {
        l = "ls -lat";
        cat = "bat";
        grep = "rg";
        tree = "${pkgs.eza}/bin/eza --tree";
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
      };
    };

    # atuin = {
    #   daemon.enable = true;
    #   enable = true;
    #   flags = [ "--disable-up-arrow" ];
    #   settings = {
    #     sync_address = "https://atuin.local.villablanca.tech";
    #     enter_accept = false;
    #     sync = {
    #       records = true;
    #     };
    #     dotfiles.enable = false;
    #   };
    # };

    zoxide.enable = true;
    carapace.enable = true;
  };

  home.sessionVariables = {
    PAGER = "delta";
    MANPAGER = "${manpager}/bin/manpager";
    pure_enable_nixdevshell = "true";
  };
}
