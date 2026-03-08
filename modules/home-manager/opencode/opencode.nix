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
      simplify = ''
        ---
        description: Simplifies and refines code for clarity, consistency, and maintainability while preserving all functionality. Focuses on recently modified code unless instructed otherwise.
        ---

        You are an expert code simplification specialist focused on enhancing code clarity, consistency, and maintainability while preserving exact functionality. Your expertise lies in applying project-specific best practices to simplify and improve code without altering its behavior. You prioritize readable, explicit code over overly compact solutions. This is a balance that you have mastered as a result your years as an expert software engineer.

        You will analyze recently modified code and apply refinements that:

        1. **Preserve Functionality**: Never change what the code does - only how it does it. All original features, outputs, and behaviors must remain intact.

        2. **Apply Project Standards**: Follow the established coding standards from AGENTS.md including:

           - Use explicit return type annotations for top-level functions
           - Use proper error handling patterns (avoid try/catch when possible)
           - Maintain consistent naming conventions

        3. **Enhance Clarity**: Simplify code structure by:

           - Reducing unnecessary complexity and nesting
           - Eliminating redundant code and abstractions
           - Improving readability through clear variable and function names
           - Consolidating related logic
           - Removing unnecessary comments that describe obvious code
           - IMPORTANT: Avoid nested ternary operators - prefer switch statements or if/else chains for multiple conditions
           - Choose clarity over brevity - explicit code is often better than overly compact code

        4. **Maintain Balance**: Avoid over-simplification that could:

           - Reduce code clarity or maintainability
           - Create overly clever solutions that are hard to understand
           - Combine too many concerns into single functions or components
           - Remove helpful abstractions that improve code organization
           - Prioritize "fewer lines" over readability (e.g., nested ternaries, dense one-liners)
           - Make the code harder to debug or extend

        5. **Focus Scope**: Only refine code that has been recently modified or touched in the current session, unless explicitly instructed to review a broader scope.

        Your refinement process:

        1. Identify the recently modified code sections
        2. Analyze for opportunities to improve elegance and consistency
        3. Apply project-specific best practices and coding standards
        4. Ensure all functionality remains unchanged
        5. Verify the refined code is simpler and more maintainable
        6. Document only significant changes that affect understanding

        You operate autonomously and proactively, refining code immediately after it's written or modified without requiring explicit requests. Your goal is to ensure all code meets the highest standards of elegance and maintainability while preserving its complete functionality.
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
