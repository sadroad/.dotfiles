{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;

        options = {
          shiftwidth = 2;
          tabstop = 2;
        };

        utility = {
          leetcode-nvim.enable = true;
          yazi-nvim = {
            enable = true;
            mappings.openYazi = "<leader>e";
          };
          motion = {
            precognition.enable = true;
          };
        };

        clipboard = {
          enable = true;
          registers = "unnamedplus";
        };

        keymaps = [
          {
            key =
              if pkgs.stdenv.isDarwin
              then "<D-/>"
              else "<C-/>";
            desc = "Toggle Line Comment";
            mode = "n";
            action = ''
              function()
                vim.api.nvim_feedkeys("gcc", "x", true)
              end
            '';
            lua = true;
          }
          {
            key =
              if pkgs.stdenv.isDarwin
              then "<D-/>"
              else "<C-/>";
            desc = "Toggle Line Comment";
            mode = "v";
            action = ''
              function()
                vim.api.nvim_feedkeys("gcc", "v", true)
              end
            '';
            lua = true;
          }
        ];

        debugger = {
          nvim-dap = {
            enable = true;
            ui.enable = true;
          };
        };

        notes = {
          todo-comments.enable = true;
        };

        comments.comment-nvim = {
          enable = true;
        };

        autocomplete.blink-cmp.enable = true;

        autopairs.nvim-autopairs.enable = true;

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
          hardtime-nvim.enable = true;
        };

        telescope.enable = true;

        treesitter.context.enable = true;

        theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
        };

        lsp = {
          enable = true;
          formatOnSave = true;
        };

        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          # web stuff
          ts = {
            enable = true;
            format.type = "biome";
          };
          css.enable = true;
          tailwind.enable = true;
          html.enable = true;
          astro.enable = true;

          nix.enable = true;
          rust = {
            enable = true;
            crates.enable = true;
          };
          assembly.enable = true;
          python.enable = true;
          markdown.enable = true;
          yaml.enable = true;
          typst.enable = true;
        };
      };
    };
  };
}
