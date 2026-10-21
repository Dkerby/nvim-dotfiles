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
-- Mason needs unzip for most packages:
--   Arch:   sudo pacman -S unzip
--   Ubuntu: sudo apt install unzip
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
-- rustfmt and clang-format come with the Rust and C/C++ installs below.
-- prettier (JSON) is installed through npm on both distros:
--   npm install -g prettier
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
    rust = { 'rustfmt' },
    c = { 'clang_format' },
    cpp = { 'clang_format' },
    json = { 'prettier' },
    jsonc = { 'prettier' },
    -- java and cs have no entry: they fall back to jdtls / csharp-ls formatting
  },
  -- prettier (node startup) and jdtls can take longer than 500ms
  format_on_save = { timeout_ms = 1500, lsp_format = 'fallback' },
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
-- main branch API: parsers are compiled with the tree-sitter CLI and highlighting
-- is started per buffer by Neovim (the old nvim-treesitter.configs module is gone)
--   Arch:   sudo pacman -S tree-sitter-cli gcc
--   Ubuntu: sudo apt install build-essential && cargo install --locked tree-sitter-cli
--           (apt's tree-sitter-cli is too old for nvim-treesitter main)
require('nvim-treesitter').install({
  'solidity', 'rust', 'c', 'cpp', 'cmake', 'make', 'toml', 'java', 'c_sharp', 'json',
  'lua', 'vim', 'vimdoc', 'regex', 'bash', 'markdown', 'markdown_inline',
})

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)  -- no-op for filetypes without a parser
  end,
})

-- ── Diagnostics ───────────────────────────────────────────────────────────────
vim.diagnostic.config({ virtual_text = true, severity_sort = true })

-- ── Rust LSP ──────────────────────────────────────────────────────────────────
--   Arch:   sudo pacman -S rustup
--   Ubuntu: sudo apt install rustup   (24.04+; older releases use https://rustup.rs)
-- then on both:
--   rustup default stable && rustup component add rust-analyzer clippy rustfmt
-- If `rust-analyzer` still isn't on PATH (Arch's rustup ships no shim for it):
--   ln -s "$(command -v rustup)" ~/.local/bin/rust-analyzer
vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  -- Cargo.lock first so files in workspace members attach to the workspace root
  root_markers = { 'Cargo.lock', 'rust-project.json', 'Cargo.toml', '.git' },
  settings = {
    ['rust-analyzer'] = {
      check = { command = 'clippy' },
      cargo = { allFeatures = true },
    },
  },
})
vim.lsp.enable('rust_analyzer')

-- ── C/C++ LSP ─────────────────────────────────────────────────────────────────
--   Arch:   sudo pacman -S clang            (includes clangd and clang-format)
--   Ubuntu: sudo apt install clangd clang-format
-- clangd reads compile_commands.json from the project root or build/
vim.lsp.config('clangd', {
  cmd = {
    'clangd',
    '--background-index',
    '--clang-tidy',
    '--header-insertion=iwyu',
    '--completion-style=detailed',
  },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  root_markers = { '.clangd', 'compile_commands.json', 'compile_flags.txt', 'CMakeLists.txt', '.git' },
})
vim.lsp.enable('clangd')

-- ── Java LSP ──────────────────────────────────────────────────────────────────
-- jdtls needs a JDK 21+ and python3 (for its launcher script):
--   Arch:   sudo pacman -S jdk-openjdk python
--   Ubuntu: sudo apt install openjdk-21-jdk python3
-- then in Neovim: :MasonInstall jdtls
vim.lsp.config('jdtls', {
  -- jdtls needs its own -data dir per project, so build the command from root_dir
  cmd = function(dispatchers, config)
    local data_dir = vim.fn.stdpath('cache') .. '/jdtls/' .. config.root_dir:gsub('/', '%%')
    return vim.lsp.rpc.start({ 'jdtls', '-data', data_dir }, dispatchers, { cwd = config.root_dir })
  end,
  filetypes = { 'java' },
  root_markers = { 'mvnw', 'gradlew', 'settings.gradle', 'settings.gradle.kts', 'pom.xml', 'build.gradle', 'build.gradle.kts', '.git' },
})
-- a function cmd skips Neovim's "is it installed" check, so do it here to avoid
-- an error on every Java file before jdtls is installed (restart after installing)
if vim.fn.executable('jdtls') == 1 then
  vim.lsp.enable('jdtls')
end

-- ── C# LSP ────────────────────────────────────────────────────────────────────
-- csharp-ls needs the .NET 10 SDK:
--   Arch:   sudo pacman -S dotnet-sdk
--   Ubuntu: sudo apt install dotnet-sdk-10.0
-- then in Neovim: :MasonInstall csharp-language-server
local function find_root(bufnr, pattern)
  return vim.fs.root(bufnr, function(name) return name:match(pattern) ~= nil end)
end

vim.lsp.config('csharp_ls', {
  cmd = { 'csharp-ls' },
  filetypes = { 'cs' },
  -- csharp-ls registers its features for the 'csharp' language id, not the 'cs' filetype
  get_language_id = function() return 'csharp' end,
  -- prefer the solution over the nearest project file
  root_dir = function(bufnr, on_dir)
    local root = find_root(bufnr, '%.slnx?$') or find_root(bufnr, '%.csproj$')
    if root then on_dir(root) end
  end,
})
vim.lsp.enable('csharp_ls')

-- ── Solidity LSP ──────────────────────────────────────────────────────────────
-- Install the server first with :MasonInstall nomicfoundation-solidity-language-server
-- (needs Node.js: `sudo pacman -S nodejs npm` / `sudo apt install nodejs npm`)
vim.lsp.config('nomicfoundation_solidity', {
  cmd = { 'nomicfoundation-solidity-language-server', '--stdio' },
  filetypes = { 'solidity' },
  root_markers = { 'hardhat.config.js', 'hardhat.config.ts', 'foundry.toml', 'package.json', '.git' },
})
vim.lsp.enable('nomicfoundation_solidity')

-- ── Keymaps ───────────────────────────────────────────────────────────────────
require('mappings')
