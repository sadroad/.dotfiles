{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  opencode = pkgs.symlinkJoin {
    name = "opencode-with-wakatime";
    paths = [ inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/opencode \
        --prefix PATH : ${
          lib.makeBinPath [
            pkgs.wakatime-cli
            pkgs.nixd
          ]
        }
    '';
  };
  opencode-desktop = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.desktop;
in
{
  # home.packages = [ opencode-desktop ];
  programs.opencode = {
    enable = true;
    package = opencode;
    enableMcpIntegration = true;
    commands = {
      rmslop = ''
        ---
        description: Remove AI code slop
        ---

        Check the diff using `jj diff`, and remove all AI generated slop introduced in this branch. Before removal, changes you'd like to make to the user for confirmation.

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
        "opencode-wakatime@v1.2.2"
      ];
      mcp = {
      };
      # // lib.optionalAttrs (config ? age.secrets.zai-key) {
      #   "zai-mcp-server" = {
      #     type = "local";
      #     command = [
      #       (pkgs.writeShellScript "zai-mcp-server" ''
      #         set -euo pipefail
      #         export Z_AI_API_KEY="$(cat ${config.age.secrets.zai-key.path})"
      #         export Z_AI_MODE="ZAI"
      #         exec ${pkgs.bun}/bin/bunx -y @z_ai/mcp-server
      #       '')
      #     ];
      #   };
      # };
    };
  };

  xdg.configFile."opencode/skills".source = ./skills;
}
