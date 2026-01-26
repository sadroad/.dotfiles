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
                    def pom [] {
            # 1. Setup Binaries (Clean abstraction for Nix paths)
            let gum = "${pkgs.gum}/bin/gum"
            let timer = "${pkgs.timer}/bin/timer"
            let notifier = if ($nu.os-info.name == "macos") {
                "${pkgs.terminal-notifier}/bin/terminal-notifier"
            } else {
                "${pkgs.libnotify}/bin/notify-send"
            }

            # 2. Select Split
            # We capture the output here because we need the value. 
            # If cancelled (Ctrl+C), 'complete' captures the failure.
            let selection = (do -i { ^$gum choose "25/5" "50/10" "all done" --header "Split?" } | complete)
            
            if $selection.exit_code != 0 { return } # Exit if user Ctrl+C's the menu
            
            let split = ($selection.stdout | str trim)
            
            # 3. Logic Map
            let time = match $split {
                "25/5" => { work: "25m", break: "5m" }
                "50/10" => { work: "50m", break: "10m" }
                _ => { return }
            }

            # 4. Work Timer
            # We run this directly with 'do -i'. We DO NOT assign it to a variable.
            # This ensures stdout goes straight to your terminal.
            do -i { ^$timer $time.work }

            if ($env.LAST_EXIT_CODE == 0) {
                # Send Notification
                if ($nu.os-info.name == "macos") {
                    run-external $notifier "-message" "Work Done" "-title" "Pomodoro" "-sound" "Crystal"
                } else {
                    run-external $notifier "Pomodoro" "Work Done" "-u" "critical"
                }

                # 5. Break Confirmation
                # We run gum confirm directly. No pipes. No variables.
                do -i { ^$gum confirm "Ready for a break?" }
                
                if ($env.LAST_EXIT_CODE == 0) {
                    # User said YES
                    do -i { ^$timer $time.break }

                    if ($env.LAST_EXIT_CODE == 0) {
                        # Break Done
                        if ($nu.os-info.name == "macos") {
                            run-external $notifier "-message" "Break Over" "-title" "Pomodoro" "-sound" "Crystal"
                        } else {
                            run-external $notifier "Pomodoro" "Break Over" "-u" "critical"
                        }
                    } else {
                        # Break Interrupted -> Restart
                        pom
                    }
                } else {
                    # User said NO (or Esc) -> Restart
                    pom
                }
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
