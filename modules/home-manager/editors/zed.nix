{
  pkgs,
  lib,
  config,
  inputs,
  home-manager,
  ...
}: {
  home.packages = with pkgs; [
    nixd
  ];
  programs.zed-editor = {
    extensions = ["nix" "kdl"];
    enable = true;
    userSettings = {
      vim_mode = true;
      telemetry = {
        metrics = false;
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
