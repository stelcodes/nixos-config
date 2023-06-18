-----------------------------------------------------------------------------
-- GLOBAL FUNCTIONS

SubstituteYanked = function()
  vim.api.nvim_input(':%s/<c-r>\"//gc<left><left><left>')
end

SearchWord = function()
  vim.api.nvim_input('viwy/<c-r>\"<cr>N')
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
-- Enable the mouse
vim.opt.mouse = 'a'
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
vim.opt.clipboard='unnamedplus'
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
vim.opt.number = false
vim.opt.relativenumber = false
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
vim.opt.whichwrap='h,l'
-- keep cursor centered vertically while scrolling
vim.opt.scrolloff = 999
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

vim.g['clojure_fuzzy_indent_patterns'] = {'^with', '^def', '^let', '^try', '^do'}
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
vim.keymap.set('n', 'U', SearchWord)
-- Start substition of text in first register
vim.keymap.set('n', 'R', SubstituteYanked)

-- WINDOWS
-- Navigate windows by direction
vim.keymap.set('n', '<c-j>', '<C-w>j')
vim.keymap.set('n', '<c-k>', '<C-w>k')
vim.keymap.set('n', '<c-h>', '<c-w>h')
vim.keymap.set('n', '<c-l>', '<c-w>l')
-- Delete current buffer, also avoid Ex mode
vim.keymap.set('n', '<c-q>', '<cmd>bd<cr>')
vim.keymap.set('t', '<c-q>', '<esc><cmd>bd!<cr>')

vim.keymap.set('n', '<c-x>', '<cmd>split %<cr>')

-- TABS
-- Navigate tabs
vim.keymap.set('n', 'T', '<cmd>tabprevious<cr>')
vim.keymap.set('n', 't', '<cmd>tabnext<cr>')
-- Move tabs
vim.keymap.set('n', '<c-left>', '<cmd>tabmove -1<cr>')
vim.keymap.set('n', '<c-right>', '<cmd>tabmove +1<cr>')
-- Open new tab with clone of current buffer
vim.keymap.set('n', '<c-t>', function() vim.cmd "tab split" end)

-- SCROLLING
-- tab moves cursor 10 lines down, shift-tab 10 lines up
vim.keymap.set('n', '<tab>', '10j')
vim.keymap.set('n', '<s-tab>', '10k')
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
vim.keymap.set('x', 'K', ':move \'<-2<CR>gv-gv')
vim.keymap.set('x', 'J', ':move \'>+1<CR>gv-gv')
-- Keeps selection active when indenting so you can do it multiple times quickly
vim.keymap.set('x', '>', '>gv')
vim.keymap.set('x', '<', '<gv')

-- QUICKFIX
vim.keymap.set('n', 'q', '<nop>') -- I don't use vim macros atm
vim.keymap.set('n', 'qq', ':copen<cr>')
vim.keymap.set('n', 'qw', ':cclose<cr>')
vim.keymap.set('n', 'qe', ':.cc<cr>')

-- OTHER STUFF
-- Copy relative path of file
vim.keymap.set('n', 'f', ':let @+=expand("%")<cr>:echo expand("%")<cr>')
-- Copy absolute path of file
vim.keymap.set('n', 'F', ':let @+=expand("%:p")<cr>:echo expand("%:p")<cr>')
-- Clear search highlighting
-- <c-/> doesn't work in tmux for some reason
vim.keymap.set('n', '<c-n>', ':let @/=""<cr>')
vim.keymap.set('i', '<c-n>', ':let @/=""<cr>')
-- Open Git Fugitive, make it full window in a new tab positioned before other tabs
-- This could be improved bc right now it clobbers existing window arrangements in the tab
vim.keymap.set('n', '<c-g>', ':Git<cr>:only<cr>')
-- Remap visual block mode because I use <c-v> for paste
vim.keymap.set('n', '<c-b>', '<c-v>')
-- Make terminal mode easy to exit
vim.keymap.set('t', '<esc>', '<c-\\><c-n>')
vim.keymap.set('t', '<c-q>', 'q')
--Debugging syntax highlighting
vim.keymap.set('n', '<f10>', ':echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . "> trans<" . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<cr>')
-- Toggle spell
vim.keymap.set('n', '<c-s>', ':set spell!<cr>')

---------------------------------------------------------------------------------
-- EVENT BASED COMMANDS

vim.cmd [[
augroup init
  " Remove all autocommands to prevent duplicates on config reload
  autocmd!
  " Update a buffer if it has changed when a FocusGained or BufEnter event happens
  autocmd FocusGained,BufEnter * checktime
  " Wrap text for certain filetypes
  autocmd FileType markdown setlocal wrap
  " Option sort_by = 'tabs' isn't working. This is a workaround.
  " autocmd TabNew * BufferLineSortByTabs
  " Keep gitsigns line indicators up to date
  " autocmd FocusGained,BufEnter * Gitsigns refresh
augroup END
]]

