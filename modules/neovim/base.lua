-----------------------------------------------------------------------------
-- GLOBAL FUNCTIONS

SearchReplace = function()
  vim.cmd('noau normal! "vy"')
  -- TODO: Sanitize / and ? chars in Lua via vim.fn.getreg('v')
  -- Substitute with verynomagic contents of register v, with multiple matches on each line,
  -- and put cursor in replacement text position
  vim.api.nvim_input(':%s/\\V<c-r>v//gc<left><left><left>')
end

SearchSelection = function()
  vim.cmd('noau normal! "vy"')
  -- TODO: Sanitize / and ? chars in Lua via vim.fn.getreg('v')
  -- Search with verynomagic contents of register v, begin, skip back to last match
  vim.api.nvim_input('/\\V<c-r>v<cr>N')
end

SearchClear = function()
  vim.fn.setreg("/", "")
end

ToggleParedit = function()
  if vim.g.paredit_mode == 0 then
    vim.g.paredit_mode = 1
    print("paredit on")
  else
    vim.g.paredit_mode = 0
    print("paredit off")
  end
  -- Sometimes paredit seems to not get turned back on, this is a workaround
  vim.cmd 'edit'
end

ToggleNumbers = function()
  if vim.o.number or vim.o.relativenumber then
    vim.o.number = false
    vim.o.relativenumber = false
  else
    vim.o.number = true
    vim.o.relativenumber = true
  end
end

----------------------------------------------------------------------------------
-- OPTIONS

vim.cmd 'filetype plugin indent on'
-- Preview pane for substitution
vim.opt.inccommand = 'split'

vim.opt.autoindent = true

vim.opt.backspace = 'indent,eol,start'

vim.opt.complete = '.,w,b,u,t'

vim.opt.smarttab = true

vim.opt.nrformats = 'bin,hex'

vim.opt.incsearch = true

vim.opt.laststatus = 2

vim.opt.ruler = true

vim.opt.wildmenu = true

vim.opt.scrolloff = 1

vim.opt.sidescrolloff = 5

vim.opt.display = 'lastline,msgsep'

vim.opt.autoread = true
-- Stop newline continution of comments
vim.opt.formatoptions = 'qlj'

vim.opt.history = 1000

vim.opt.tabpagemax = 50
-- save undo history
vim.opt.undofile = true
-- treat dash separated words as a word text object
vim.opt.iskeyword = { '@', '48-57', '_', '192-255', '-', '#' }
-- Required to keep multiple buffers open
vim.opt.hidden = true
-- The encoding displayed
vim.opt.encoding = 'utf-8'
-- The encoding written to file
vim.opt.fileencoding = 'utf-8'
-- Disable the mouse
vim.opt.mouse = ''
-- Insert 2 spaces for a tab
vim.opt.tabstop = 2
-- Change the number of space characters inserted for indentation
vim.opt.shiftwidth = 2
-- Converts tabs to spaces
vim.opt.expandtab = true
-- Makes indenting smart
vim.opt.smartindent = true
-- Faster completion
vim.opt.updatetime = 300
-- Wait forever for mappings
vim.opt.timeout = false
-- Copy paste between vim and everything else
vim.opt.clipboard = 'unnamedplus'
-- Display long lines as just one line
vim.opt.wrap = false
-- Makes popup menu smaller
vim.opt.pumheight = 10
-- Enables syntax highlighing
vim.cmd 'syntax enable'
-- Show the cursor position all the time
vim.opt.ruler = true
-- More space for displaying messages
vim.opt.cmdheight = 2
-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
-- Enable highlighting of the current line
vim.opt.cursorline = false
-- Always show tabs
vim.opt.showtabline = 2
-- We don't need to see things like -- INSERT -- anymore
vim.opt.showmode = false
-- Always show the signcolumn in the number column
vim.opt.signcolumn = 'yes'
-- Setting this fixed my tmux rendering issues :)
vim.opt.lazyredraw = true
-- Horizontal splits will automatically be below
vim.opt.splitbelow = true
-- Vertical splits will automatically be to the right
vim.opt.splitright = true
-- Break lines at word boundaries for readability
vim.opt.linebreak = true
-- Have dark background by default
vim.opt.bg = 'dark'
-- Allow left/right scrolling to jump lines
vim.opt.whichwrap = 'h,l'
-- keep cursor centered vertically while scrolling
vim.opt.scrolloff = 10
-- make minimum width for number column smallest value so it doesn't take up much room
vim.opt.numberwidth = 1
-- write to file often
vim.opt.autowrite = true
-- enable full color support
vim.opt.termguicolors = true
-- ignore case when searching
vim.opt.ignorecase = true
-- don't ignore case when searching with capital letters
vim.opt.smartcase = true
-- turn swapfiles off
vim.opt.swapfile = false

----------------------------------------------------------------------------------------
-- GLOBALS

vim.g['clojure_fuzzy_indent_patterns'] = { '^with', '^def', '^let', '^try', '^do' }
vim.g['clojure_align_multiline_strings'] = 0
vim.g['clojure_align_subforms'] = 1
-- Number of lines formatting will affect by default, 0 is no limit
vim.g['clojure_maxlines'] = 0

----------------------------------------------------------------------------------------
-- MAPPINGS

-- LEADER
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set('n', '<Space>', '<Nop>')
vim.keymap.set('x', '<leader>', '<Nop>')

-- TEXT MANIPULATION
-- Yank word under cursor
vim.keymap.set('n', 'Y', 'viwy')
vim.keymap.set({ 'n', 'x' }, '<leader>ss', SearchSelection)
vim.keymap.set({ 'n', 'x' }, '<leader>sr', SearchReplace)
vim.keymap.set({ 'n', 'x' }, '<leader><leader>', SearchClear)

-- BUFFERS
vim.keymap.set('n', '<leader>bb', '<c-^>') -- buffer back
vim.keymap.set('n', '<leader>bd', '<cmd>bd<cr>')
vim.keymap.set('n', '<leader>bn', '<cmd>bn<cr>')
vim.keymap.set('n', '<leader>bp', '<cmd>bp<cr>')
vim.keymap.set('n', '<leader>bf', '<cmd>bf<cr>')
vim.keymap.set('n', '<leader>bl', '<cmd>bl<cr>')

-- DIAGNOSTICS
vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>dk', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<leader>dj', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setqflist)

-- WINDOWS
-- Navigate windows by direction
vim.keymap.set('n', '<c-j>', '<cmd>wincmd j<cr>')
vim.keymap.set('n', '<c-k>', '<cmd>wincmd k<cr>')
vim.keymap.set('n', '<c-h>', '<cmd>wincmd h<cr>')
vim.keymap.set('n', '<c-l>', '<cmd>wincmd l<cr>')
vim.keymap.set('n', '<c-q>', '<cmd>wincmd q<cr>')
vim.keymap.set('n', '<c-x>', '<cmd>split %<cr>')

-- TABS
-- Navigate tabs
vim.keymap.set('n', 'T', '<cmd>tabnext<cr>')
-- vim.keymap.set('n', 't', '<cmd>tabnext #<cr>')
vim.keymap.set('n', 't', function()
  local ok, _ = pcall(vim.cmd, 'tabnext #')
  if not ok then vim.cmd 'tabnext' end
end)
-- Move tabs
vim.keymap.set('n', '<c-left>', '<cmd>tabmove -1<cr>')
vim.keymap.set('n', '<c-right>', '<cmd>tabmove +1<cr>')
-- Open new tab with clone of current buffer
vim.keymap.set('n', '<c-t>', function() vim.cmd "tab split" end)
vim.keymap.set('n', '<leader>1', '<cmd>tabnext 1<cr>')
vim.keymap.set('n', '<leader>2', '<cmd>tabnext 2<cr>')
vim.keymap.set('n', '<leader>3', '<cmd>tabnext 3<cr>')
vim.keymap.set('n', '<leader>4', '<cmd>tabnext 4<cr>')
vim.keymap.set('n', '<leader>5', '<cmd>tabnext 5<cr>')
vim.keymap.set('n', '<leader>6', '<cmd>tabnext 6<cr>')
vim.keymap.set('n', '<leader>7', '<cmd>tabnext 7<cr>')
vim.keymap.set('n', '<leader>8', '<cmd>tabnext 8<cr>')
vim.keymap.set('n', '<leader>9', '<cmd>tabnext 9<cr>')

-- SCROLLING
-- Moves cursor 10 lines down or up
vim.keymap.set('n', 'J', '10j') -- I can still join lines in visual mode
vim.keymap.set('n', 'K', '10k')
-- move through wrapped lines visually
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('x', 'j', 'gj')
vim.keymap.set('x', 'k', 'gk')

-- Make carriage return do nothing
vim.keymap.set('n', '<cr>', '<nop>')
-- Avoid ex mode
vim.keymap.set('n', 'Q', '<nop>')

-- SELECTIONS
-- Text manipulation
vim.keymap.set('x', '<c-k>', ':move \'<-2<CR>gv-gv')
vim.keymap.set('x', '<c-j>', ':move \'>+1<CR>gv-gv')
-- Keeps selection active when indenting so you can do it multiple times quickly
vim.keymap.set('x', '>', '>gv')
vim.keymap.set('x', '<', '<gv')

-- QUICKFIX
vim.keymap.set('n', 'q', '<cmd>copen<cr>')
vim.keymap.set('n', 'Q', '<cmd>cclose<cr>')
-- vim.keymap.set('n', 'M', '<cmd>normal! q') -- start macro

-- OTHER STUFF
-- Copy relative path of file
vim.keymap.set('n', 'f', ':let @+=expand("%")<cr>:echo expand("%")<cr>')
-- Copy absolute path of file
vim.keymap.set('n', 'F', ':let @+=expand("%:p")<cr>:echo expand("%:p")<cr>')
-- Clear search highlighting
-- <c-/> doesn't work in tmux for some reason
vim.keymap.set('n', '<c-,>', ':let @/=""<cr>')
vim.keymap.set('i', '<c-,>', ':let @/=""<cr>')
-- Open Git Fugitive, make it full window in a new tab positioned before other tabs
-- This could be improved bc right now it clobbers existing window arrangements in the tab
vim.keymap.set('n', '<c-g>', '<cmd>Git<cr>')
vim.keymap.set('n', '<c-o>', '<cmd>only<cr>')
-- Make terminal mode easy to exit
vim.keymap.set('t', '<c-\\><esc>', '<c-\\><c-n>')
--Debugging syntax highlighting
vim.keymap.set('n', '<f10>',
  ':echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . "> trans<" . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<cr>')
-- Toggle spell
vim.keymap.set('n', '<c-s>', ':set spell!<cr>')
vim.keymap.set('n', '<c-p>', ToggleParedit)
vim.keymap.set('n', '<c-n>', ToggleNumbers)

---------------------------------------------------------------------------------
-- EVENT BASED COMMANDS

vim.filetype.add({
  extension = {
    age = 'age',
  },
})

local general = vim.api.nvim_create_augroup('general', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'age',
  group = general,
  command = 'setlocal noendofline nofixendofline',
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  group = general,
  command = 'setlocal wrap',
})

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  pattern = '*',
  group = general,
  command = 'checktime',
})
