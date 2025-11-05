{
  pkgs,
  inputs,
  lib,
  userDir,
  ...
}: let
  saveClipbordToFileYaziPlugin = pkgs.fetchFromGitHub {
    owner = "boydaihungst";
    repo = "save-clipboard-to-file.yazi";
    rev = "3309c787646556beadddf4e4c28fcf3ebf52920b";
    sha256 = "sha256-9UYfakBFWMq4ThWjnZx7q2lIPrVnli1QSSOZfcQli/s=";
  };
  nix-alien = inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}.nix-alien;
  opencode = pkgs.callPackage ./opencode.nix {};
in {
  home.sessionVariables = {
    EDITOR = "nvim";
    NH_SEARCH_PLATFORM = "true";
  };
  home.packages = with pkgs;
    [
      eza
      bat
      dust
      fd
      ripgrep
      procs
      gping
      doggo
      pigz
      hexyl
      ouch

      #deploy tools
      nixos-anywhere
      deploy-rs
      compose2nix

      hyperfine
      hydra-check
      asciinema_3
      nix-output-monitor
      cloudflared
      pv
      zellij
      opencode
      caligula
      pastel
      numbat
      railway
      ngrok
      gitleaks
      gnupg
      mediainfo
      tokei
      nix-alien
    ]
    ++ (lib.optionals pkgs.stdenv.isLinux [
      dysk
    ]);

  programs.fzf = {
    enable = true;
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    flake = "${userDir}/.dotfiles";
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        forwardAgent = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        compression = false;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
        extraOptions = lib.optionalAttrs pkgs.stdenv.isDarwin {
          "UseKeychain" = "yes";
        };
      };
      "tux" = {
        hostname = "tux.cs.drexel.edu";
        user = "av676";
      };
    };
  };

  programs.yazi = {
    enable = true;
    plugins = {
      save-clipboard-to-file = saveClipbordToFileYaziPlugin;
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          on = ["p" "c"];
          run = "plugin save-clipboard-to-file";
        }
      ];
    };
  };

  xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    layout = "stretch";
  };
  xdg.configFile."opencode/AGENTS.md".text = ''
    Never touch the git history or make any modifications. If you want to make a change, ask the user first to confirm it.

    Try to use jj instead of git directly
  '';
}
