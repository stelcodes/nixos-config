"""""""""""""""""""""""""""""""""""""""""""""""""""""
" Leader

let mapleader=" "
let maplocalleader=" "
nnoremap <Space> <Nop>
xnoremap <leader> <Nop>

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" Substitution

" preview pane
set icm=split

nnoremap <leader>y viwy
nnoremap <leader>u :call StartSubstitution()<CR>

function! StartSubstitution()
  call nvim_input(":%s/<C-r>\"//gc<left><left><left>")
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" General Settings
" see https://github.com/ChristianChiarulli/nvim

" save undo history
set undofile
" treat dash separated words as a word text object
set iskeyword+=-
" Stop newline continution of comments
set formatoptions-=cro
" Required to keep multiple buffers open
set hidden
" The encoding displayed
set encoding=utf-8
" The encoding written to file
set fileencoding=utf-8
" Enable your mouse
set mouse=a
" Insert 2 spaces for a tab
set tabstop=2     
" Change the number of space characters inserted for indentation
set shiftwidth=2  
" Converts tabs to spaces
set expandtab     
" Makes indenting smart
set smartindent   
" Faster completion
set updatetime=300
" Wait forever fo mappings
set notimeout
" Copy paste between vim and everything else
set clipboard=unnamedplus     
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Visuals

" Display long lines as just one line
set nowrap
" Makes popup menu smaller
set pumheight=10
" Enables syntax highlighing
syntax enable
" Show the cursor position all the time
set ruler
" More space for displaying messages
set cmdheight=2
" Line numbers
set number        
" Enable highlighting of the current line
set cursorline    
" Always show tabs
set showtabline=2 
" We don't need to see things like -- INSERT -- anymore
set noshowmode    
" enable full color support
set termguicolors 
" Always show the signcolumn, otherwise it would shift the text each time
set signcolumn=yes
" Setting this fixed my tmux rendering issues :)
set lazyredraw
" Horizontal splits will automatically be below
set splitbelow
" Vertical splits will automatically be to the right
set splitright
" Break lines at word boundaries for readability
set linebreak
set bg=dark
" set t_ut=
" set term=screen-256color
"""""""""""""""""""""""""""""""""""""""""""""""""""""
" Navigating

" stel's original window navigation solution
" ctrl-[hjkl] moves window focus in that direction, moving to another tab
" if necessary
function! MoveLeft()
  if (winnr() == winnr('1h'))
    :tabprevious
  else
    :call nvim_input("<Esc><C-w>h")
  endif
endfunction

function! MoveRight()
  if (winnr() == winnr('1l'))
    :tabnext
  else
    :call nvim_input("<Esc><C-w>l")
  endif
endfunction

nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> :call MoveLeft()<CR>
nnoremap <C-l> :call MoveRight()<CR>

inoremap <C-j> <Esc><C-w>j
inoremap <C-k> <Esc><C-w>k
inoremap <C-h> <Esc>:call MoveLeft()<CR>
inoremap <C-l> <Esc>:call MoveRight()<CR>

tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-h> <C-\><C-n>:call MoveLeft()<CR>
tnoremap <C-l> <C-\><C-n>:call MoveRight()<CR>

" tab moves cursor 10 lines down, shift-tab 10 lines up
nnoremap <silent> <TAB> 10j
nnoremap <silent> <S-TAB> 10k

" move through wrapped lines visually
nnoremap j gj
nnoremap k gk

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" Auto complete

" <TAB>: completion.
inoremap <silent> <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text manipulation

" Move selected line / block of text in visual mode
xnoremap K :move '<-2<CR>gv-gv
xnoremap J :move '>+1<CR>gv-gv

" Keeps selection active when indenting so you can do it multiple times quickly
vnoremap > >gv
vnoremap < <gv

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" my personal ctrl prefixed commmands
nnoremap <C-q> :q<CR>
nnoremap <C-t> :tabnew<CR>
nnoremap <C-s> :source ~/.config/nvim/init.vim<CR>
nnoremap <C-d> :cd %:h<CR>
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <C-c> :let @/=""<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""
" lightline config
set noshowmode
let g:lightline = {
      \ 'colorscheme': 'nord',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&readonly?"":""}',
      \   'obsession': '%{ObsessionStatus(" ")}'
      \ },
      \ 'component_function': {
      \   'gitbranch': 'LightlineFugitive',
      \ },
      \ 'separator':    { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' },
      \ 'tabline': {
      \   'left': [['tabs']],
      \   'right': [['obsession']]
      \ }
      \ }
function! LightlineFugitive()
    if exists('*FugitiveHead')
	let branch = FugitiveHead()
	return branch !=# '' ? ' '.branch : ''
    endif
    return ''
endfunction
"""""""""""""""""""""""""""""""""""""""""""""""""""""
" Event Triggers

" this makes it so vim will update a buffer if it has changed
" on the filesystem when a FocusGained or BufEnter event happens
autocmd FocusGained,BufEnter * :checktime
autocmd FileType c,cpp,cs,java setlocal commentstring=//\ %s "change comment style for commentary.vim
autocmd FileType markdown setlocal wrap
"""""""""""""""""""""""""""""""""""""""""""""""""""""
" Terminal
tnoremap <Esc> <C-\><C-n>
"""""""""""""""""""""""""""""""""""""""""""""""""""""
" Debugging neovim
nnoremap <f10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<cr>r
