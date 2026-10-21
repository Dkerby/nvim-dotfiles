local map = vim.keymap.set

-- ── Insert mode navigation ───────────────────────────────────────────────────
map('i', '<C-b>', '<ESC>^i', { desc = 'Move beginning of line' })
map('i', '<C-e>', '<End>',   { desc = 'Move end of line' })
map('i', '<C-h>', '<Left>',  { desc = 'Move left' })
map('i', '<C-l>', '<Right>', { desc = 'Move right' })
map('i', '<C-j>', '<Down>',  { desc = 'Move down' })
map('i', '<C-k>', '<Up>',    { desc = 'Move up' })

-- ── Window navigation ────────────────────────────────────────────────────────
map('n', '<C-h>', '<C-w>h', { desc = 'Switch window left' })
map('n', '<C-l>', '<C-w>l', { desc = 'Switch window right' })
map('n', '<C-j>', '<C-w>j', { desc = 'Switch window down' })
map('n', '<C-k>', '<C-w>k', { desc = 'Switch window up' })

-- ── General ──────────────────────────────────────────────────────────────────
map('n', '<Esc>', '<cmd>noh<CR>',   { desc = 'Clear highlights' })
map('n', '<C-s>', '<cmd>w<CR>',     { desc = 'Save file' })
map('n', '<C-c>', '<cmd>%y+<CR>',   { desc = 'Copy whole file' })

-- ── Toggle options ───────────────────────────────────────────────────────────
map('n', '<leader>n',  '<cmd>set nu!<CR>',  { desc = 'Toggle line number' })
map('n', '<leader>rn', '<cmd>set rnu!<CR>', { desc = 'Toggle relative number' })

-- ── Format (conform.nvim) ────────────────────────────────────────────────────
map({ 'n', 'x' }, '<leader>fm', function()
  require('conform').format({ lsp_fallback = true })
end, { desc = 'Format file' })

-- ── LSP ──────────────────────────────────────────────────────────────────────
map('n', '<leader>ds', vim.diagnostic.setloclist, { desc = 'Diagnostic loclist' })

-- Built-in defaults also apply: K hover, grn rename, gra code action,
-- grr references, gri implementation, gO symbols, [d / ]d diagnostics
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local function bmap(lhs, rhs, desc)
      map('n', lhs, rhs, { buffer = bufnr, desc = desc })
    end

    bmap('gd', vim.lsp.buf.definition,      'Go to definition')
    bmap('gD', vim.lsp.buf.declaration,     'Go to declaration')
    bmap('gy', vim.lsp.buf.type_definition, 'Go to type definition')

    if client and client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      bmap('<leader>ih', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
      end, 'Toggle inlay hints')
    end

    if client and client.name == 'clangd' then
      bmap('<leader>ch', function()
        local params = vim.lsp.util.make_text_document_params(bufnr)
        client:request('textDocument/switchSourceHeader', params, function(err, uri)
          if err or not uri then
            vim.notify('No matching source/header found', vim.log.levels.WARN)
            return
          end
          vim.cmd.edit(vim.uri_to_fname(uri))
        end, bufnr)
      end, 'Switch source/header')
    end
  end,
})

-- ── Buffers ──────────────────────────────────────────────────────────────────
map('n', '<leader>b', '<cmd>enew<CR>',    { desc = 'New buffer' })
map('n', '<Tab>',     '<cmd>bnext<CR>',   { desc = 'Next buffer' })
map('n', '<S-Tab>',   '<cmd>bprev<CR>',   { desc = 'Prev buffer' })

vim.keymap.set("n", "<leader>x", function()
  require("mini.bufremove").delete(0, false)
end, { desc = "Close buffer" })

-- -- ── Comments (Neovim 0.10+ built-in gc/gcc) ─────────────────────────────────
map('n', '<leader>/', 'gcc', { desc = 'Toggle comment', remap = true })
map('v', '<leader>/', 'gc',  { desc = 'Toggle comment', remap = true })

-- ── File explorer (neo-tree) ─────────────────────────────────────────────────
map('n', '<C-n>',     '<cmd>Neotree toggle<CR>', { desc = 'Toggle file explorer' })
map('n', '<leader>e', '<cmd>Neotree focus<CR>',  { desc = 'Focus file explorer' })

-- ── Telescope ────────────────────────────────────────────────────────────────
map('n', '<leader>ff', '<cmd>Telescope find_files<CR>',                                    { desc = 'Find files' })
map('n', '<leader>fa', '<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>', { desc = 'Find all files' })
map('n', '<leader>fw', '<cmd>Telescope live_grep<CR>',                                     { desc = 'Live grep' })
map('n', '<leader>fb', '<cmd>Telescope buffers<CR>',                                       { desc = 'Find buffers' })
map('n', '<leader>fh', '<cmd>Telescope help_tags<CR>',                                     { desc = 'Help tags' })
map('n', '<leader>fo', '<cmd>Telescope oldfiles<CR>',                                      { desc = 'Recent files' })
map('n', '<leader>fz', '<cmd>Telescope current_buffer_fuzzy_find<CR>',                     { desc = 'Find in buffer' })
map('n', '<leader>ma', '<cmd>Telescope marks<CR>',                                         { desc = 'Find marks' })
map('n', '<leader>cm', '<cmd>Telescope git_commits<CR>',                                   { desc = 'Git commits' })
map('n', '<leader>gt', '<cmd>Telescope git_status<CR>',                                    { desc = 'Git status' })

-- ── Terminal ─────────────────────────────────────────────────────────────────
map('t', '<C-x>', '<C-\\><C-N>', { desc = 'Escape terminal mode' })

map('n', '<leader>h', '<cmd>split | terminal<CR>',  { desc = 'New horizontal terminal' })
map('n', '<leader>v', '<cmd>vsplit | terminal<CR>', { desc = 'New vertical terminal' })

-- Toggleable terminals (A-h horizontal, A-v vertical, A-i floating)
local term_bufs = {}

local function toggle_term(pos, id)
  local buf = term_bufs[id]

  -- If window is open, close it
  if buf and vim.api.nvim_buf_is_valid(buf) then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == buf then
        vim.api.nvim_win_close(win, false)
        return
      end
    end
  end

  local reuse = buf and vim.api.nvim_buf_is_valid(buf)

  if pos == 'float' then
    local cols, lines = vim.o.columns, vim.o.lines
    local w = math.floor(cols * 0.8)
    local h = math.floor(lines * 0.8)
    local new_buf = reuse and buf or vim.api.nvim_create_buf(false, true)
    vim.api.nvim_open_win(new_buf, true, {
      relative = 'editor',
      width = w, height = h,
      row = math.floor((lines - h) / 2),
      col = math.floor((cols  - w) / 2),
      style = 'minimal', border = 'rounded',
    })
    if not reuse then
      vim.fn.termopen(vim.o.shell)
    end
    term_bufs[id] = vim.api.nvim_get_current_buf()
  else
    local cmd = pos == 'vsp' and 'vsplit' or 'split'
    if reuse then
      vim.cmd(cmd)
      vim.api.nvim_set_current_buf(buf)
    else
      vim.cmd(cmd .. ' | terminal')
      term_bufs[id] = vim.api.nvim_get_current_buf()
    end
  end

  vim.cmd('startinsert')
end

map({ 'n', 't' }, '<A-v>', function() toggle_term('vsp',   'vterm') end, { desc = 'Toggle vertical terminal' })
map({ 'n', 't' }, '<A-h>', function() toggle_term('sp',    'hterm') end, { desc = 'Toggle horizontal terminal' })
map({ 'n', 't' }, '<A-i>', function() toggle_term('float', 'fterm') end, { desc = 'Toggle floating terminal' })

vim.keymap.set('n', '<Tab>', ':bnext<CR>')
vim.keymap.set('n', '<S-Tab>', ':bprev<CR>')
