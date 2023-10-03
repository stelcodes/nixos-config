-- https://github.com/nvim-telescope/telescope.nvim#previewers
local tele = require('telescope')
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')
local browser = tele.extensions.file_browser
local manix = tele.extensions.manix

local find_files_from_root = function()
  builtin.find_files {
    hidden = true,
    no_ignore = true,
    no_ignore_parent = true,
    search_dirs = { '/etc', '/home', '/usr' }
  }
end
local browse_notes = function()
  browser.file_browser {
    hidden = false,
    respect_gitignore = false,
    path = '/home/stel/sync/notes'
  }
end
local git_status = function()
  builtin.git_status({ default_text = vim.fn.expand('%:t'), initial_mode = "normal" })
end

tele.setup {
  defaults = {
    file_ignore_patterns = {
      '%.pdf$', '%.db$', '%.opus$', '%.mp3$', '%.wav$', '%.git/', '%.clj%-kondo/%.cache/', '%.lsp/', '%.cpcache/',
      '%target/'
    },
    show_untracked = false, -- For git_files command
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
      }
    },
    -- Add hidden flag for grep to search hidden flag.
    vimgrep_arguments = {
      'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', '--hidden'
    }
  },
  extensions = {
    file_browser = {
      -- Open file browser in directory of currently focused file
      hidden = true,
      path = "%:p:h",
      initial_mode = "normal",
      mappings = {
        n = {
          h = browser.actions.goto_parent_dir,
          l = actions.select_default,
          d = browser.actions.trash,
          -- to match nnn
          n = browser.actions.create,
          -- x = trash_browser_selection,
          x = browser.actions.trash,
          t = actions.file_tab,
          ['.'] = browser.actions.toggle_hidden
        }
      }
    },
    fzf = {
      fuzzy = true,                   -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true,    -- override the file sorter
      case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
    }
  }
}
tele.load_extension('ui-select')
tele.load_extension('file_browser')
tele.load_extension('manix')
tele.load_extension('fzf')
vim.keymap.set('n', '<leader>ff', builtin.find_files)
vim.keymap.set('n', '<leader>fb', browser.file_browser)
vim.keymap.set('n', '<leader>fr', find_files_from_root)
vim.keymap.set('n', '<leader>fn', browse_notes)
vim.keymap.set('n', '<leader>r', builtin.resume)
vim.keymap.set('n', '<leader>sf', function() builtin.live_grep { hidden = true } end)
vim.keymap.set('n', '<leader>sF',
  function() builtin.live_grep { hidden = true, additional_args = { "--max-count", "1" } } end)
vim.keymap.set('n', '<leader>ds', builtin.diagnostics)
vim.keymap.set('n', '<leader>p', builtin.registers)
vim.keymap.set('n', '<leader>m', builtin.marks)
vim.keymap.set('n', '<leader>M', manix.manix)
vim.keymap.set('n', '<leader>c', builtin.commands)
vim.keymap.set('n', '<leader>C', function() builtin.colorscheme { enable_preview = true } end)
vim.keymap.set('n', '<leader>h', builtin.help_tags)
vim.keymap.set('n', '<leader>bs', builtin.buffers)
vim.keymap.set('n', '<leader>sb', builtin.current_buffer_fuzzy_find)
vim.keymap.set('n', '<leader>k', builtin.keymaps)
vim.keymap.set('n', '<leader>t', builtin.builtin)
vim.keymap.set('n', '<leader>gc', builtin.git_bcommits)
vim.keymap.set('n', '<leader>gC', builtin.git_commits)
vim.keymap.set('n', '<leader>gf', builtin.git_files)
vim.keymap.set('n', '<leader>gd', builtin.git_status)
vim.keymap.set('n', '<leader>gd', git_status)
vim.keymap.set('n', '<leader>lr', builtin.lsp_references)
