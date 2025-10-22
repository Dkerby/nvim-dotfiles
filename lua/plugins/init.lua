return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  { "nvim-tree/nvim-tree.lua", enabled = false },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false, -- lualine will load itself
    -- opts = {
    --   options = {
    --     theme = "horizon", -- or your preferred theme
    --   },
    -- },
    -- config = function(_, opts)
    --   require("lualine").setup(opts)
    --
    --   -- Override the background color to black
    --   vim.api.nvim_set_hl(0, "lualine_c_normal", { bg = "#0D0D0D", fg = "#b9b9b9" })
    --
    --   -- Repeat for other modes if needed (insert, visual, replace, command)
    --   vim.api.nvim_set_hl(0, "lualine_c_insert", { bg = "#0D0D0D", fg = "#b9b9b9" })
    --
    --   vim.api.nvim_set_hl(0, "lualine_c_command", { bg = "#0D0D0D", fg = "#b9b9b9" })
    --
    --   vim.api.nvim_set_hl(0, "lualine_c_visual", { bg = "#0D0D0D", fg = "#b9b9b9" })
    --
    --   vim.api.nvim_set_hl(0, "lualine_c_replace", { bg = "#0D0D0D", fg = "#b9b9b9" })
    -- end,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      panel = { enabled = false }, -- no side panel
      suggestion = {
        enabled = true, -- inline ghost text only
        auto_trigger = true, -- show as you type
        debounce = 75,
        keymap = {
          accept = "<Tab>", -- or change to something else
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require "cmp"
      local copilot = require "copilot.suggestion"

      -- override only the <Tab> mapping
      opts.mapping["<Tab>"] = function(fallback)
        if copilot.is_visible() then
          copilot.accept()
        elseif cmp.visible() then
          cmp.confirm { select = true }
        else
          fallback()
        end
      end
    end,
  },
  -- {
  --   "mmsaki/forgefmt.nvim",
  --     config = function()
  --       require("forgefmt").setup({
  --         auto_format = true, -- enable autoformat on save
  --       })
  --     end,
  --     lazy = false, -- load on startup
  -- },
  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
