-- https://github.com/nvim-telescope/telescope.nvim#previewers
local tele = require('telescope')
local builtin = require('telescope.builtin')
local open_with_trouble = require("trouble.sources.telescope").open
-- local add_to_trouble = require("trouble.sources.telescope").add

tele.setup {
  defaults = {
    file_ignore_patterns = { '%.lock$', '%.pdf$', '%.db$', '%.opus$', '%.mp3$', '%.wav$', '%.git/', '%.clj%-kondo/%.cache/', '%.lsp/', '%.cpcache/', '%target/' },
    show_untracked = false, -- For git_files command
    mappings = {
      i = { ["<c-t>"] = open_with_trouble },
      n = { ["<c-t>"] = open_with_trouble },
    },
    layout_strategy = 'flex',
    layout_config = {
      height = 0.99,
      width = 0.95,
      flex = {
        flip_columns = 160,
        flip_lines = 20,
      },
      horizontal = {
        preview_width = 0.6,
        -- Always show preview
        preview_cutoff = 0
      },
      vertical = {
        preview_height = 0.6,
        -- Always show preview
        preview_cutoff = 0
      },
    },
    -- Add hidden flag for grep to search hidden flag.
    vimgrep_arguments = {
      'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', '--hidden'
    }
  },
  extensions = {
    fzf = {
      fuzzy = true,                   -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true,    -- override the file sorter
      case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
    }
  }
}
tele.load_extension('ui-select')
tele.load_extension('fzf')
vim.keymap.set('n', '<leader><leader>', builtin.resume)
vim.keymap.set('n', '<leader>f', builtin.find_files)                                 -- files directory
vim.keymap.set('n', '<leader>s', function() builtin.live_grep { hidden = true } end) -- search directory
vim.keymap.set('n', '<leader>S',                                                     -- search directory with max 1 match per file
  function() builtin.live_grep { hidden = true, additional_args = { "--max-count", "1" } } end)
vim.keymap.set('n', '<leader>b',
  function() builtin.live_grep { search_dirs = { vim.fn.expand("%:p") } } end) -- Regex search current file
vim.keymap.set('n', '<leader>B', builtin.current_buffer_fuzzy_find)
vim.keymap.set('n', '<leader>dd', builtin.diagnostics)
vim.keymap.set('n', '<leader>r', builtin.registers)
vim.keymap.set('n', '<leader>m', builtin.marks)
vim.keymap.set('n', '<leader>c', builtin.commands)
vim.keymap.set('n', '<leader>C', function() builtin.colorscheme { enable_preview = true } end)
vim.keymap.set('n', '<leader>h', builtin.help_tags)
vim.keymap.set('n', '<leader>k', builtin.keymaps)
vim.keymap.set('n', '<leader>t', builtin.builtin)
vim.keymap.set('n', '<leader>lr', builtin.lsp_references)
