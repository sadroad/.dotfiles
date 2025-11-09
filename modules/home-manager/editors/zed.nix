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
    alejandra
  ];
  programs.zed-editor = {
    extensions = ["nix" "kdl" "tsgo" "oxc" "make" "catppuccin-icons" "wakatime" "toml"];
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
