-- leader must be set before plugins load
vim.g.mapleader = ' '

vim.pack.add({
  'https://github.com/bjarneo/pixel.nvim',
  'https://github.com/esmuellert/codediff.nvim',
  -- version tag enables auto-download of the prebuilt Rust fuzzy-matcher binary
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.*') },
  'https://github.com/nvim-lua/plenary.nvim',        -- required by telescope + neo-tree
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/williamboman/mason.nvim',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
  -- neo-tree and its dependencies
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range('3') },
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  -- treesitter
  'https://github.com/nvim-treesitter/nvim-treesitter',
  -- noice and its dependencies
  'https://github.com/rcarriga/nvim-notify',
  'https://github.com/folke/noice.nvim',
  -- mini pairs
  'https://github.com/echasnovski/mini.pairs',
  -- mini tabline
  'https://github.com/echasnovski/mini.tabline',
  'https://github.com/echasnovski/mini.bufremove'
})

-- ── Options ───────────────────────────────────────────────────────────────────
vim.opt.clipboard     = 'unnamedplus'
vim.opt.termguicolors = true
vim.opt.number        = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes' 

-- ── Filetype detection ────────────────────────────────────────────────────────
vim.filetype.add({ extension = { sol = 'solidity' } })

-- ── Colorscheme ───────────────────────────────────────────────────────────────
vim.opt.fillchars = { eob = ' ' }

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = 'pixel',
  callback = function()
    local groups = { 'Normal', 'NormalNC', 'NormalFloat', 'SignColumn', 'LineNr', 'EndOfBuffer' }
    for _, group in ipairs(groups) do
      vim.api.nvim_set_hl(0, group, { ctermbg = 'NONE', bg = 'NONE' })
    end
  end,
})

vim.cmd.colorscheme('pixel')

require('mini.pairs').setup()

require('mini.tabline').setup({
  format = function(buf_id, label)
    local modified = vim.bo[buf_id].modified and ' ● ' or ' | '
    return label .. modified
  end,
})

require("mini.bufremove").setup()

-- ── codediff.nvim ─────────────────────────────────────────────────────────────
require('codediff').setup({})

-- ── mason.nvim ────────────────────────────────────────────────────────────────
require('mason').setup()

-- ── nvim-notify ───────────────────────────────────────────────────────────────
require('notify').setup({
  background_colour = '#000000',
  stages = 'static',
  render = 'minimal',
})

-- ── noice.nvim ────────────────────────────────────────────────────────────────
require('noice').setup({
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
    },
  },
  popupmenu = { enabled = false },
  presets = {
    bottom_search = true,        -- classic bottom cmdline for / and ?
    long_message_to_split = true,
    lsp_doc_border = true,
  },
  views = {
    cmdline_popup = {
      position = { row = '50%', col = '50%' },
      border = { style = 'rounded' },
    },
    popupmenu = {
      border = { style = 'rounded' },
    },
  },
})

-- ── blink.cmp ─────────────────────────────────────────────────────────────────
require('blink.cmp').setup({
  keymap = {
    preset = 'none',
    ['<Tab>']   = { 'accept', 'fallback' },
    ['<Up>']    = { 'select_prev', 'fallback' },
    ['<Down>']  = { 'select_next', 'fallback' },
    ['<Esc>']   = { 'hide', 'fallback' },
  },
  appearance = { nerd_font_variant = 'mono' },
  completion = { documentation = { auto_show = true }, menu = { enabled = false } },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer'},
  },
  fuzzy = { implementation = 'prefer_rust_with_warning' },
  cmdline = {
    enabled = false,  -- ← disables blink in / ? : command line entirely
  },
})

-- Expose blink.cmp capabilities to every LSP server (Neovim 0.11+ vim.lsp.config)
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- ── conform.nvim ──────────────────────────────────────────────────────────────
require('conform').setup({
  formatters = {
    verible_verilog_format = {
      command = 'verible-verilog-format',
      args = { '-' },
      stdin = true,
    },
  },
  formatters_by_ft = {
    systemverilog = { 'verible_verilog_format' },
    verilog = { 'verible_verilog_format' },
    rust = { 'rustfmt'}
  },
  format_on_save = { timeout_ms = 500, lsp_format = 'fallback' },
})

-- ── telescope.nvim ────────────────────────────────────────────────────────────
require('telescope').setup()

-- ── gitsigns.nvim ─────────────────────────────────────────────────────────────
require('gitsigns').setup({
  on_attach = function(bufnr)
    local gs = require('gitsigns')
    local function map(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
    end

    -- hunk navigation (respects vimdiff ]c/[c)
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(gs.next_hunk)
      return '<Ignore>'
    end, 'Next hunk')
    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(gs.prev_hunk)
      return '<Ignore>'
    end, 'Prev hunk')

    map('n', '<leader>hs', gs.stage_hunk,                                               'Stage hunk')
    map('n', '<leader>hr', gs.reset_hunk,                                               'Reset hunk')
    map('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Stage selected hunk')
    map('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Reset selected hunk')
    map('n', '<leader>hS', gs.stage_buffer,                                             'Stage buffer')
    map('n', '<leader>hR', gs.reset_buffer,                                             'Reset buffer')
    map('n', '<leader>ph', gs.preview_hunk,                                             'Preview hunk')
    map('n', '<leader>gb', function() gs.blame_line({ full = true }) end,               'Blame line')
    map('n', '<leader>hd', gs.diffthis,                                                 'Diff this')
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>',                          'Select hunk')
  end,
})

-- ── neo-tree.nvim ─────────────────────────────────────────────────────────────
require('neo-tree').setup({
  close_if_last_window = true,
  popup_border_style = '',         -- uses 'winborder' (Neovim 0.11+)
  filesystem = {
    filtered_items = {
      visible = false,
      hide_dotfiles = false,
      hide_gitignored = true,
    },
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
  },
  window = {
    width = 20,
    mappings = {
      ['<C-h>'] = function() vim.cmd('wincmd h') end,
      ['<C-l>'] = function() vim.cmd('wincmd l') end,
    },
  },
})

-- ── nvim-treesitter ───────────────────────────────────────────────────────────
local ts_ok, ts_configs = pcall(require, 'nvim-treesitter.configs')
if ts_ok then
  ts_configs.setup({
    ensure_installed = { 'solidity', 'rust', 'lua', 'vim', 'vimdoc', 'regex', 'bash', 'markdown', 'markdown_inline' },
    auto_install = true,
    highlight = { enable = true },
  })
end

-- ── Solidity LSP ──────────────────────────────────────────────────────────────
-- Install the server first with :MasonInstall nomicfoundation-solidity-language-server
vim.lsp.config('nomicfoundation_solidity', {
  cmd = { 'nomicfoundation-solidity-language-server', '--stdio' },
  filetypes = { 'solidity' },
  root_markers = { 'hardhat.config.js', 'hardhat.config.ts', 'foundry.toml', 'package.json', '.git' },
})
vim.lsp.enable('nomicfoundation_solidity')

-- ── Keymaps ───────────────────────────────────────────────────────────────────
require('mappings')
