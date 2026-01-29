{ pkgs, inputs, ... }:
{
  programs.helix = {
    defaultEditor = true;
    enable = true;
    extraPackages = with pkgs; [
      nodePackages.typescript-language-server
      astro-language-server

      nil
      nixd

      vscode-json-languageserver

      ty
      ruff
      python3Packages.python-lsp-server
      python3Packages.python-lsp-ruff
      python3Packages.jedi-language-server
    ];
    settings = {
      theme = "gruvbox";
      editor = {
        line-number = "relative";
        cursorline = true;
        bufferline = "multiple";
        color-modes = true;
        indent-guides = {
          render = true;
        };
      };
    };
    languages = {
      language-server = {
        wakatime = {
          command = "${
            inputs.wakatime-ls.packages.${pkgs.stdenv.hostPlatform.system}.default
          }/bin/wakatime-ls";
        };
        nil = {
          config.nil = {
            nix = {
              flake = {
                autoArchive = true;
              };
            };
          };
        };
      };
      language = [
        {
          name = "numbat";
          scope = "source.numbat";
          injection-regex = "numbat";
          file-types = [ "nbt" ];
          comment-token = "#";
          roots = [ "." ];
        }
        {
          name = "nix";
          language-servers = [
            "nixd"
            "nil"
            "wakatime"
          ];
          auto-format = true;
          formatter = {
            command = "${pkgs.nixfmt}/bin/nixfmt";
            args = [
              "--filename=%{buffer_name}"
            ];
          };
        }
        {
          name = "rust";
          language-servers = [
            "rust-analyzer"
            "wakatime"
          ];
          auto-format = true;
        }
        {
          name = "c";
          language-servers = [
            "clangd"
            "wakatime"
          ];
        }
      ];
      grammar = [
        {
          name = "numbat";
          source = {
            git = "https://github.com/irevoire/tree-sitter-numbat";
            rev = "4d9ce55767f7cc2a0ef97dd070de7e4519920607";
          };
        }
      ];
    };
  };
  xdg.configFile."helix/runtime/queries/numbat/highlights.scm".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/irevoire/tree-sitter-numbat/4d9ce55767f7cc2a0ef97dd070de7e4519920607/queries/highlights.scm";
    sha256 = "0bj7f6kgjjcia9cbxpznjgmnax0mii3kr7s9d69rp07b1rlyw9la";
  };
}
