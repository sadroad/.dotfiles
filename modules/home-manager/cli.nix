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
  claude-code-pkg = pkgs.callPackage ./custom/claude/package.nix {};
  glimpse = inputs.glimpse.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  home.sessionVariables = {
    EDITOR = "nvim";
    NH_NO_CHECKS = "1";
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

      #deploy tools
      nixos-anywhere
      deploy-rs
      compose2nix

      hyperfine
      neofetch
      hydra-check
      claude-code-pkg
      asciinema_3
      nix-output-monitor
      cloudflared
      glimpse
      pv
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
    addKeysToAgent = "yes";
    extraConfig =
      lib.optionalString pkgs.stdenv.isDarwin "UseKeychain yes";
    matchBlocks = {
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
