{pkgs, ...}: {
  home.packages = with pkgs; [
    nixd
    alejandra
  ];
  programs.zed-editor = {
    extensions = ["nix" "kdl" "tsgo" "oxc" "make" "catppuccin-icons" "wakatime" "toml" "comment" "haskell" "typst"];
    enable = true;
    userSettings = {
      agent_servers = {
        OpenCode = {
          type = "custom";
          command = "opencode";
          args = ["acp"];
        };
      };
      vim_mode = true;
      telemetry = {
        metrics = false;
      };
      inlay_hints = {
        enabled = true;
      };
      languages = {
        Nix = {
          language_servers = ["nixd"];
          formatter = {
            external = {
              command = "alejandra";
              arguments = ["--quiet" "--"];
            };
          };
        };
        Python = {
          language_servers = ["ty" "basedpyright" "..."];
        };
      };
      vim = {
        toggle_relative_line_numbers = true;
      };
      ui_font_size = 14;
      buffer_font_size = 14;
      load_direnv = "shell_hook";
      ui_font_family = "Berkeley Mono Variable";
      buffer_font_family = "Berkeley Mono Variable";
      ui_font_features = {
        calt = 1;
      };
    };
  };
}
