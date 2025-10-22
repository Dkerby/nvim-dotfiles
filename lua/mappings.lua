require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local unmap = vim.keymap.del

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<leader>e", ":Neotree toggle<CR>", { silent = true, desc = "Toggle Neo-tree" })
unmap("n", "<C-n>")  -- unmap the default netrw toggle
map("n", "<C-n>", ":Neotree filesystem reveal left<CR>", {})
map("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})


-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
