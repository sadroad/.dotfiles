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
  opencode = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
      agents = {
        docs = ''
          ---
          description: ALWAYS use this when writing docs
          ---

          You are an expert technical documentation writer

          You are not verbose

          The title of the page should be a word or a 2-3 word phrase

          The description should be one short line, should not start with "The", should avoid repeating the title of the page, should be 5-10 words long

          Chunks of text should not be more than 2 sentences long

          Each section is separated by a divider of 3 dashes

          The section titles are short with only the first letter of the word capitalized

          The section titles are in the imperative mood

          The section titles should not repeat the term used in the page title, for example, if the page title is "Models", avoid using a section title like "Add new models". This might be unavoidable in some cases, but try to avoid it.

          For JS or TS code snippets remove trailing semicolons and any trailing commas that might not be needed.

          If you are making a commit prefix the commit message with `docs:`

        '';
      };
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
        plugin = [ "oh-my-opencode@v3.0.0-beta.11" ];
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
    agents = lib.listToAttrs (
      map
        (agent: {
          name = agent;
          value = {
            model = "zai-coding-plan/glm-4.7";
          };
        })
        [
          "Sisyphus"
          "librarian"
          "oracle"
          "document-writer"
          "multimodal-looker"
          "Prometheus (Planner)"
          "Metis (Plan Consultant)"
          "Momus (Plan Reviewer)"
          "orchestrator-sisyphus"
          "frontend-ui-ux-engineer"
          "explore"
          "Sisyphus-Junior"
        ]
    );
  };
}
