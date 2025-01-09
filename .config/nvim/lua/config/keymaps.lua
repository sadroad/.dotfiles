-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local comment_key = vim.fn.has("macunix") == 1 and "<D-/>" or "<C-/>"
vim.keymap.set({ "n", "v" }, comment_key, "gcc", { remap = true, desc = "Comment line/s" })
