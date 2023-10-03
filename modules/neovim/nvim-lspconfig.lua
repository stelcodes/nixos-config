-- https://github.com/neovim/nvim-lspconfig
local lspconfig = require('lspconfig')

lspconfig.clojure_lsp.setup {}
lspconfig.pyright.setup {}
lspconfig.gopls.setup {}
lspconfig.tsserver.setup {}
lspconfig.java_language_server.setup {}
lspconfig.rust_analyzer.setup {}
lspconfig.rnix.setup {}
lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      }
    }
  }
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', '<leader>lh', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>ln', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>lf', function()
      vim.lsp.buf.format { async = true }
    end, opts)
    vim.keymap.set('n', '<leader>ld', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<leader>lD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', '<leader>li', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<leader>lt', vim.lsp.buf.type_definition, opts)
    -- Getting references via telescope is bound to <leader>lr
    vim.keymap.set('n', '<leader>lR', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    -- vim.keymap.set('v', '<leader>lf', function() vim.lsp.buf.range_formatting({}) end, opts)
    -- Add borders to :LspInfo floating window
    -- https://neovim.discourse.group/t/lspinfo-window-border/1566/2
    -- require('lspconfig.ui.windows').default_options.border = 'rounded'
  end
})

-- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
--   vim.lsp.handlers.hover,
--   { border = "rounded" }
-- )
--
-- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
--   vim.lsp.handlers.signature_help,
--   { border = "rounded" }
-- )
