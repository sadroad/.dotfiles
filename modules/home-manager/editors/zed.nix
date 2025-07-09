{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  programs.zed-editor = {
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
          path_lookup = true;
        };
      };
      ui_font_size = 14;
      buffer_font_size = 14;
    };
  };
}
