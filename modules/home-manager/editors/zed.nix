{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  programs.zed-editor = {
    extensions = ["nix"];
    enable = true;
    userSettings = {
      vim_mode = true;
      features = {
        copilot = false;
      };
      telemetry = {
        metrics = false;
      };
      lsp = {
        rust-analyzer = {
          binary = {
            path_lookup = true;
          };
        };
        nix = {
          binary = {
            path_lookup = true;
          };
        };
      };
      ui_font_size = 14;
      buffer_font_size = 14;
      load_direnv = "shell_hook";
    };
  };
}
