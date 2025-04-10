return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      racket_langserver = {
        cmd = { "racket", "--lib", "racket-langserver", "--", "--stdio" },
        filetypes = { "racket", "scheme" },
      },
      rust_analyzer = {
        mason = false,
      },
    },
  },
}
