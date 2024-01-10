call plug#begin()
" post install (yarn install | npm install) then load plugin only for editing supported files
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install --frozen-lockfile --production',
  \ 'for': ['javascript', 'typescript','typescriptreact', 'javascriptreact', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html'] }
Plug 'https://github.com/ap/vim-buftabline.git'
Plug 'https://github.com/907th/vim-auto-save.git'

Plug 'https://github.com/mindriot101/vim-yapf.git'
Plug 'https://github.com/preservim/nerdcommenter.git'
Plug 'https://github.com/morhetz/gruvbox.git'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'voldikss/vim-floaterm'
Plug 'tomasiser/vim-code-dark'
Plug 'https://github.com/tpope/vim-fugitive.git'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'https://github.com/rhysd/vim-clang-format.git'
Plug 'lervag/vimtex'
Plug 'whonore/Coqtail'
Plug 'hut/ranger'
Plug 'tpope/vim-surround' 
Plug 'https://github.com/tpope/vim-repeat'
Plug 'https://github.com/VonHeikemen/lsp-zero.nvim.git'
Plug 'napmn/react-extract.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" LSP Support
Plug 'neovim/nvim-lspconfig'                           " Required
Plug 'williamboman/mason.nvim', {'do': ':MasonUpdate'} " Optional
Plug 'williamboman/mason-lspconfig.nvim'               " Optional
Plug 'https://github.com/ThePrimeagen/refactoring.nvim.git'
Plug 'nvim-lua/plenary.nvim'
Plug 'https://github.com/mrcjkb/haskell-tools.nvim.git'

" Autocompletion
Plug 'hrsh7th/nvim-cmp'     " Required
Plug 'hrsh7th/cmp-nvim-lsp' " Required
Plug 'L3MON4D3/LuaSnip'     " Required

Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v2.x'}
" Optional:
Plug 'honza/vim-snippets'
Plug 'https://github.com/maksimr/vim-jsbeautify.git'
Plug 'https://github.com/itchyny/lightline.vim.git'
Plug 'sheerun/vim-polyglot'
Plug 'https://github.com/jalvesaq/Nvim-R.git'
Plug 'christoomey/vim-tmux-navigator'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'https://github.com/ryanoasis/vim-devicons.git'
Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }

call plug#end()
lua require("ntree")
lua require("lsp")




" All system-wide defaults are set in $VIMRUNTIME/debian.vim and sourced by
" the call to :runtime you can find below.  If you wish to change any of those
" settings, you should do it in this file (/etc/vim/vimrc), since debian.vim
" will be overwritten everytime an upgrade of the vim packages is performed.
" It is recommended to make changes after sourcing debian.vim since it alters
" the value of the 'compatible' option.

runtime! debian.vim

" Vim will load $VIMRUNTIME/defaults.vim if the user does not have a vimrc.
" This happens after /etc/vim/vimrc(.local) are loaded, so it will override
" any settings in these files.
" If you don't want that to happen, uncomment the below line to prevent
" defaults.vim from being loaded.
" let g:skip_defaults_vim = 1

" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
"set compatible

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
if has("syntax")
  syntax on
endif

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
"set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
"au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
"filetype plugin indent on

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
set showcmd		" Show (partial) command in status line.
"set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
set autowrite		" Automatically save before commands like :next and :make
set hidden		" Hide buffers when they are abandoned
set mouse=a		" Enable mouse usage (all modes)
" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif
" Set internal encoding of vim, not needed on neovim, since coc.nvim using some
" unicode characters in the file autoload/float.vim
set encoding=utf-8

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set hidden
nnoremap <C-N> :bnext<CR>
nnoremap <C-P> :bprev<CR>
".vimrc
autocmd FileType javascript noremap <buffer>  <c-f> :Prettier<cr>
" for json
autocmd FileType json noremap <buffer> <c-f> :call JsonBeautify()<cr>
" for jsx
autocmd FileType jsx noremap <buffer> <c-f> :Prettier<cr>
autocmd FileType typescriptreact noremap <buffer> <c-f> :Prettier<cr>
autocmd FileType typescript noremap <buffer> <c-f> :Prettier<cr>
" for html
autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>
" for css or scss
autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>

autocmd FileType python noremap <buffer> <c-f> :0,$!yapf<cr>
autocmd FileType c noremap <buffer> <c-f> :ClangFormat<cr>
autocmd FileType cpp noremap <buffer> <c-f> :ClangFormat<cr>
autocmd FileType php noremap <buffer> <c-f> :call HtmlBeautify()<cr>


" Copy to 'clipboard registry'
vmap <C-c> "+y

" Select all text
inoremap <F9> <C-O>za
nnoremap <F9> za
onoremap <F9> <C-C>za
vnoremap <F9> zf
let g:python_highlight_space_errors = 0
inoremap <expr> <c-x><c-k> SpellCheck("\<c-x>\<c-k>")
nnoremap z= :<c-u>call SpellCheck()<cr>z=
function! SpellCheck(...)
  let s:spell_restore = &spell
  set spell
  augroup restore_spell_option
    autocmd!
    autocmd CursorMoved,CompleteDone <buffer> let &spell = s:spell_restore | autocmd! restore_spell_option
  augroup END
  return a:0 ? a:1 : ''
endfunction
let g:clang_format#style_options = {
            \ "AccessModifierOffset" : -2,
            \ "AllowShortIfStatementsOnASingleLine" : "true",
            \ "AlwaysBreakTemplateDeclarations" : "true",
            \ "Standard" : "C++11",
	     \ "IndentWidth":4,
       \"ColumnLimit":120,
       \"DerivePointerAlignment": "false",
       \"PointerAlignment": "Right"}




" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeablehl
" delays and poor user experience.
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

map <C-j> ciw<C-r>0<ESC>
set relativenumber
set number
"
"VIMTE starts here"
" This is necessary for VimTeX to load properly. The "indent" is optional.
" Note that most plugin managers will do this automatically.
filetype plugin indent on

" Thi enables Vim's and neovim's syntax-related features. Without this, some
" VimTeX features will not work (see ":help vimtex-requirements" for more
" info).
syntax enable

" Viewer options: One may configure the viewer either by specifying a built-in
" viewer method:
let g:vimtex_view_method = 'zathura'

" Or with a generic interface:
let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'

" VimTeX uses latexmk as the default compiler backend. If you use it, which is
" strongly recommended, you probably don't need to configure anything. If you
" want another compiler backend, you can change it as follows. The list of
" supported backends and further explanation is provided in the documentation,
" see ":help vimtex-compiler".
let g:vimtex_compiler_method = 'latexrun'

" Most VimTeX mappings rely on localleader and this can be changed with the
" following line. The default is usually fine and is the symbol "\".
let maplocalleader = ","
" No background color. Persist after setting colorscheme.
" Only sets when colorsceme is set
nnoremap <expr> O getline('.') =~ '^\s*//' ? 'O<esc>S' : 'O'
nnoremap <expr> o getline('.') =~ '^\s*//' ? 'o<esc>S' : 'o'
set mouse=a
colorscheme codedark
let mapleader = ","
" Configuration example
let g:floaterm_keymap_new   = '<Leader>fn'
let g:floaterm_keymap_prev   = '<Leader>fb'
let g:floaterm_keymap_next   = '<Leader>ff'
let g:floaterm_keymap_toggle = '<Leader>ft'
let g:floaterm_keymap_kill = '<Leader>fk'
let g:fzf_preview_window = ['hidden,right,50%,<70(up,40%)', 'ctrl-/']

let g:floaterm_width = 0.8
let g:floaterm_height = 0.8
let g:prettier#config#print_width = 80

nnoremap  <leader>nf :Files <cr>
nnoremap  <leader>ns :Files /<cr>
nnoremap  <leader>nb :Buffers<cr>
nnoremap  <leader>ng :GFiles<cr>
nnoremap  <leader>na :Ag<cr>
nnoremap  <leader>nw :Windows<cr>
nnoremap  <leader>x :bd<cr>
set autochdir

nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv
:set guicursor=i:block

