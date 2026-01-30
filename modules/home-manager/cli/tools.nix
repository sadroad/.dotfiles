{
  pkgs,
  inputs,
  lib,
  userDir,
  config,
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

  opencode = pkgs.symlinkJoin {
    name = "opencode-with-wakatime";
    paths = [ inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/opencode \
        --prefix PATH : ${
          pkgs.lib.makeBinPath [
            pkgs.wakatime-cli
            pkgs.nixd
          ]
        }
    '';
  };
  pom = inputs.pom.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home.sessionVariables = {
    NH_SEARCH_PLATFORM = "true";
    OPENCODE_ENABLE_EXA = "1";
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
    opencode = {
      enable = true;
      package = opencode;
      enableMcpIntegration = true;
      commands = {
        rmslop = ''
          ---
          description: Remove AI code slop
          ---

          Check the diff using `jj diff`, and remove all AI generated slop introduced in this branch.

          This includes:

          - Extra comments that a human wouldn't add or is inconsistent with the rest of the file
          - Extra defensive checks or try/catch blocks that are abnormal for that area of the codebase (especially if called by trusted / validated codepaths)
          - Casts to any to bypass type issues
          - Any other style that is inconsistent with the file
          - Unnecessary emoji usage

          Report at the end with only a 1-3 sentence summary of what you changed
        '';
      };
      rules = ''
        Never touch the git history or make any git modifications. If you want to make a change, ask the user first to confirm it.

        Try to use jj instead of git directly
      '';
      settings = {
        layout = "stretch";
        theme = "mercury";
        plugin = [
          "oh-my-opencode@v3.1.9"
          "opencode-wakatime@v1.1.1"
        ];
        mcp = lib.optionalAttrs (config ? age.secrets.zai-key) {
          "zai-mcp-server" = {
            type = "local";
            command = [
              (pkgs.writeShellScript "zai-mcp-server" ''
                set -euo pipefail
                export Z_AI_API_KEY="$(cat ${config.age.secrets.zai-key.path})"
                export Z_AI_MODE="ZAI"
                exec ${pkgs.bun}/bin/bunx -y @z_ai/mcp-server
              '')
            ];
          };
        };
      };
    };
  };
  xdg.configFile."opencode/oh-my-opencode.json".text = builtins.toJSON {
    agents = {
      sisyphus = {
        # model = "opencode/claude-opus-4-5";
        # variant = "max";
        model = "opencode/kimi-k2.5";
      };
      oracle = {
        model = "opencode/gpt-5.2";
        variant = "high";
      };
      librarian = {
        model = "zai-coding-plan/glm-4.7";
      };
      explore = {
        model = "zai-coding-plan/glm-4.7";
      };
      multimodal-looker = {
        model = "opencode/gemini-3-flash";
      };
      prometheus = {
        model = "opencode/claude-opus-4-5";
        variant = "max";
      };
      metis = {
        model = "opencode/claude-opus-4-5";
        variant = "max";
      };
      momus = {
        model = "opencode/gpt-5.2";
        variant = "medium";
      };
      atlas = {
        # model = "opencode/claude-sonnet-4-5";
        model = "opencode/kimi-k2.5";
      };
    };
    categories = {
      "visual-engineering" = {
        model = "opencode/gemini-3-pro";
      };
      "ultrabrain" = {
        model = "opencode/gpt-5.2-codex";
        variant = "xhigh";
      };
      "artistry" = {
        model = "opencode/gemini-3-pro";
        variant = "max";
      };
      "deep" = {
        model = "openai/gpt-5.2-codex";
        variant = "medium";
      };
      "quick" = {
        model = "zai-coding-plan/glm-4.7";
      };
      "unspecified-low" = {
        # model = "opencode/claude-sonnet-4-5";
        model = "opencode/kimi-k2.5";
      };
      "unspecified-high" = {
        model = "opencode/claude-opus-4-5";
        variant = "max";
      };
      "writing" = {
        model = "opencode/kimi-k2";
      };
    };
  };
}
