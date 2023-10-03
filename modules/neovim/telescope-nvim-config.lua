-- https://github.com/nvim-telescope/telescope.nvim#previewers
local tele = require('telescope')
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local Path = require('plenary.path')
local fb = tele.extensions.file_browser
local fb_utils = require('telescope._extensions.file_browser.utils')
local manix = tele.extensions.manix

local fb_trash = function(prompt_bufnr)
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  local finder = current_picker.finder
  if vim.fn.executable "trash" ~= 1 then
    vim.notify "Cannot locate a valid trash executable!"
    return
  end
  local selections = fb_utils.get_selected_files(prompt_bufnr, true)
  if vim.tbl_isempty(selections) then
    vim.notify "No selection to be trashed!"
    return
  end
  for _, sel in ipairs(selections) do
    if sel:is_dir() then
      local abs = sel:absolute()
      if finder.files and Path:new(finder.path):parent():absolute() == abs then
        vim.notify "Parent folder cannot be trashed!"
        return
      end
      if not finder.files and Path:new(finder.cwd):absolute() == abs then
        vim.notify "Current folder cannot be trashed!"
        return
      end
    end
  end
  vim.ui.input({ prompt = "Trash selections [y/N]: " }, function(input)
    vim.cmd [[ redraw ]] -- redraw to clear out vim.ui.prompt to avoid hit-enter prompt
    if input and input:lower() == "y" then
      for _, p in ipairs(selections) do
        local is_dir = p:is_dir()
        local result = vim.fn.system("trash -- " .. p:absolute())
        if vim.v.shell_error ~= 0 then
          vim.notify(result)
          break
        else
          if is_dir then
            fb_utils.delete_dir_buf(p:absolute())
          else
            fb_utils.delete_buf(p:absolute())
          end
        end
      end
    end
    current_picker:refresh(current_picker.finder)
  end)
end

local find_files_from_root = function()
  builtin.find_files {
    hidden = true,
    no_ignore = true,
    no_ignore_parent = true,
    search_dirs = { '/etc', '/home', '/usr' }
  }
end
local browse_notes = function()
  fb.file_browser {
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
          h = fb.actions.goto_parent_dir,
          l = actions.select_default,
          d = fb_trash,
          -- to match nnn
          n = fb.actions.create,
          x = fb_trash,
          t = actions.file_tab,
          ['.'] = fb.actions.toggle_hidden
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
vim.keymap.set('n', '<leader>fb', fb.file_browser)
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
