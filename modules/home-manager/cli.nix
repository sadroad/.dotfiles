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
  glimpse =
    if inputs ? glimpse
    then inputs.glimpse.packages.${pkgs.stdenv.hostPlatform.system}.default
    else null;
  nh-pkg =
    if inputs ? nh
    then inputs.nh.packages.${pkgs.stdenv.hostPlatform.system}.default
    else null;
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

      #deploy tools
      nixos-anywhere
      deploy-rs
      compose2nix

      hyperfine
      neofetch
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
    ]
    ++ (lib.optional (glimpse != null) glimpse)
    ++ (lib.optionals pkgs.stdenv.isLinux [
      dysk
    ]);

  programs.fzf = {
    enable = true;
  };

  programs.nh = lib.mkIf (nh-pkg != null) {
    enable = true;
    package = nh-pkg;
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
}
