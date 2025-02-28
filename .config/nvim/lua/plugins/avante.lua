return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false, -- set this if you want to always pull the latest change
  opts = {
    provider = "claude",
    auto_suggestions_provider = "deepseek",
    claude = {
      api_key_name = "cmd:infisical --token=st.762083c7-2acc-4978-a60c-806ed8b1a40a.6394e05cebe3961e56514bb966a1353f.66914af33927ddbabe2fc985565e966b --domain=https://infisical.local.villablanca.tech secrets --silent get --plain ANTHROPIC_API_KEY",
      reasoning_effort = "high",
    },
    behaviour = {
      auto_suggestions = true,
    },
    vendors = {
      deepseek = {
        __inherited_from = "openai",
        api_key_name = "cmd:infisical --token=st.762083c7-2acc-4978-a60c-806ed8b1a40a.6394e05cebe3961e56514bb966a1353f.66914af33927ddbabe2fc985565e966b --domain=https://infisical.local.villablanca.tech secrets --silent get --plain DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-chat",
      },
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
