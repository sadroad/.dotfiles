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
in {
  home.packages = with pkgs; [
    eza
    bat
    delta
    dust
    fd
    ripgrep
    procs
    gping
    doggo
    _0x
    pigz

    hyperfine
    neofetch
  ];

  programs.fzf = {
    enable = true;
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    flake = "${userDir}/.dotfiles";
  };

  programs.yazi = {
    enable = true;
    plugins = {
      save-clipboard-to-file = saveClipbordToFileYaziPlugin;
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
