{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  programs.nvf = {
    enable = true;
    enableManpages = true;
    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;

        options = {
          shiftwidth = 2;
          tabstop = 2;
        };

        utility = {
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

        statusline = {
          lualine = {
            enable = true;
            theme = "gruvbox_dark";
          };
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
        };

        telescope.enable = true;

        theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
        };

        formatter = {
          conform-nvim.enable = true;
        };

        diagnostics = {
          nvim-lint.enable = true;
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          trouble.enable = true;
          lspsaga.enable = true;
          otter-nvim.enable = true;
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

          nix = {
            enable = true;
            lsp.server = "nixd";
          };
          rust = {
            enable = true;
            crates.enable = true;
          };
          assembly.enable = true;
          python.enable = true;
          markdown.enable = true;
          yaml.enable = true;
          typst.enable = true;
          sql.enable = true;
        };
      };
    };
  };
}
