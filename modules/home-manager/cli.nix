{
  pkgs,
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
  claude-code-pkg = pkgs.callPackage ./custom/claude/package.nix {};
in {
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  home.packages = with pkgs;
    [
      eza
      bat
      delta
      dust
      fd
      ripgrep
      procs
      gping
      doggo
      pigz
      hexyl

      hyperfine
      neofetch
      hydra-check
      claude-code-pkg
      nixos-anywhere
      deploy-rs
      asciinema_3
      compose2nix
      nix-output-monitor
    ]
    ++ (lib.optionals pkgs.stdenv.isLinux [
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
    extraConfig = ''
      Host tux
      	HostName tux.cs.drexel.edu
      	User av676
    '';
  };

  programs.yazi = {
    enable = true;
    plugins = {
      save-clipboard-to-file = saveClipbordToFileYaziPlugin;
    };
    settings = {
      manager = {
        show_hidden = true;
      };
    };
    keymap = {
      manager.prepend_keymap = [
        {
          on = ["p" "c"];
          run = "plugin save-clipboard-to-file";
        }
      ];
    };
  };
}
