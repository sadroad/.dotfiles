{pkgs, ...}: {
  programs.helix = {
    defaultEditor = true;
    enable = true;
    extraPackages = [pkgs.nodePackages.typescript-language-server];
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
      language = [
        {
          name = "numbat";
          scope = "source.numbat";
          injection-regex = "numbat";
          file-types = ["nbt"];
          comment-token = "#";
          roots = ["."];
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
    url = "https://github.com/irevoire/tree-sitter-numbat/blob/4d9ce55767f7cc2a0ef97dd070de7e4519920607/queries/highlights.scm";
    sha256 = "1z9vxlwmnvx95lqygjq52ksi04yfn5yjnyymb0qy35yf07yw3j2z";
  };
}
