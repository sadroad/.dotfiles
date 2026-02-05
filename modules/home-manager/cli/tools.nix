{
  pkgs,
  inputs,
  lib,
  userDir,
  ...
}:
let
  saveClipboardToFileYaziPlugin = pkgs.fetchFromGitHub {
    owner = "boydaihungst";
    repo = "save-clipboard-to-file.yazi";
    rev = "3309c787646556beadddf4e4c28fcf3ebf52920b";
    sha256 = "sha256-9UYfakBFWMq4ThWjnZx7q2lIPrVnli1QSSOZfcQli/s=";
  };
  inherit (inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}) nix-alien;

  pom = inputs.pom.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home.sessionVariables = {
    NH_SEARCH_PLATFORM = "true";
  };
  home.packages =
    with pkgs;
    [
      bat
      dust
      doggo
      hexyl
      ouch

      hyperfine
      hydra-check
      nix-output-monitor
      cloudflared
      pv
      caligula
      pastel
      gitleaks
      trufflehog
      mediainfo
      tokei
      typos
      gh
      ffmpeg-full
      dysk
      typst
      binsider
      pom
    ]
    ++ (lib.optionals pkgs.stdenv.isLinux [
      nix-alien
      gf
      rr
    ]);

  programs = {
    numbat.enable = true;
    fzf.enable = true;
    asciinema = {
      enable = true;
      package = pkgs.asciinema_3;
    };
    zellij = {
      enable = true;
      settings = {
        default_shell = "nu";
      };
    };
    ripgrep.enable = true;
    fd.enable = true;
    nh = {
      package = inputs.nh.packages.${pkgs.stdenv.hostPlatform.system}.nh;
      enable = true;
      clean.enable = true;
      flake = "${userDir}/.dotfiles";
    };
    ssh = {
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
    yazi = {
      enable = true;
      plugins = {
        save-clipboard-to-file = saveClipboardToFileYaziPlugin;
      };
      keymap = {
        mgr.prepend_keymap = [
          {
            on = [
              "p"
              "c"
            ];
            run = "plugin save-clipboard-to-file";
          }
        ];
      };
    };
  };
}
