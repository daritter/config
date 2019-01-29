"Run only once
if exists("homevimrc_loaded")
    finish
endif
let homevimrc_loaded = 1

" Configuration file for vim
set dir=~/.vim/tmp//	" Put swapfiles in vim dir
set encoding=utf-8
au GUIEnter * set columns=120 lines=40
set nocompatible              " be iMproved
set modeline
set mousemodel=popup_setpos
set mouse=a
set viminfo=%,'20,<50,h
set backspace=indent,eol,start	" more powerful backspacing
set textwidth=0		 " Don't wrap words by default
set nobackup		 " Don't keep a backup file
set viminfo='20,\"50	 " read/write a .viminfo file, don't store more than 50 lines of registers
set history=50		 " keep 50 lines of command line history
set switchbuf=useopen,usetab,newtab
set showcmd		 " Show (partial) command in status line.
set showmatch		 " Show matching brackets.
set ignorecase smartcase " Do case insensitive matching unless pattern contains upper case letters
set incsearch		 " Incremental search
set autowrite            " Automatically save before commands like :next and :make
set diffopt+=iwhite,vertical
set wildmenu wildmode=longest,list
set autoindent expandtab shiftwidth=2 softtabstop=2 cino=g0,hs
" Suffixes that get lower priority when doing tab completion for filenames.
" These are files we are not likely to want to edit or read.
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
"Show tabs and trailing whitespace using light markers
set listchars=tab:└─,trail:∙
set list
"Set to have a slightly different background in columns 80 and starting at 120
let &colorcolumn="80,120,121"

" Setting up Vundle - the vim plugin bundler
filetype off                  " required for vundle
let iCanHazVundle=1
let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
if !filereadable(vundle_readme)
    echo "Installing Vundle.."
    echo ""
    silent !mkdir -p ~/.vim/bundle
    silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/vundle
    let iCanHazVundle=0
endif
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'
"Add your bundles here
Bundle 'scrooloose/syntastic'
Bundle 'scrooloose/nerdcommenter'
Bundle 'Valloric/YouCompleteMe'
Bundle 'altercation/vim-colors-solarized'
Bundle 'vim-airline/vim-airline'
Bundle 'vim-airline/vim-airline-themes'
Bundle 'tpope/vim-fugitive'
Bundle 'mhinz/vim-signify'
Bundle 'vim-latex/vim-latex'
Bundle 'klen/python-mode'
Bundle 'hdima/python-syntax'
Bundle 'majutsushi/tagbar'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'tpope/vim-abolish'
if iCanHazVundle == 0
    echo "Installing Bundles, please ignore key map error messages"
    echo ""
    :BundleInstall
endif
filetype plugin indent on
syntax on

"syntastic
let g:syntastic_aggregate_errors = 1
let g:syntastic_check_on_open = 1
let g:syntastic_enable_signs = 1
let g:syntastic_enable_balloons = 1
let g:syntastic_enable_highlighting = 1
let g:syntastic_id_checkers = 1
let g:syntastic_python_checkers = ['python', 'pylama']
let g:syntastic_rst_checkers = ['sphinx']
"cpp is checked by YouCompleteMe
let g:syntastic_cpp_checkers = []
let g:syntastic_python_pylama_args = "-o ~/work/config/pylama.ini"
let g:syntastic_error_symbol = "▸"
let g:syntastic_warning_symbol = "▸"
let g:syntastic_style_error_symbol = "▹"
let g:syntastic_style_warning_symbol = "▹"
let g:syntastic_python_python_exec = 'python3'

"YouCompleteME
let g:ycm_python_binary_path = '/usr/bin/python3'
let g:ycm_global_ycm_extra_conf = '~/.vim/ycm_conf.py'
let g:ycm_extra_conf_globlist = [resolve(expand('~/belle/')) . '*']
"let g:ycm_extra_conf_vim_data = ['b:syntastic_cpp_cflags']
" Apply YCM FixIt
map <F9> :YcmCompleter FixIt<CR>

"vim airline
set t_Co=16
set laststatus=2 guifont=Hack\ Regular\ 12
"if has("gui_running")
let g:airline_theme='solarized'
set background=light
let g:solarized_contrast='normal'
let g:solarized_visibility='low'
colorscheme solarized
"else
"    let g:airline_theme='bubblegum'
"endif
highlight! link SignColumn LineNr
highlight! link SyntasticErrorSign DiffDelete
highlight! link SyntasticWarningSign DiffChange
autocmd ColorScheme * highlight! link SignColumn LineNr
let g:airline_powerline_fonts=1

"vim-signify
let g:signify_sign_overwrite = 0
let g:signify_vcs_list = [ 'git', 'svn' ]
let g:signify_diffoptions = { 'git': '-w', 'svn': '-w' }
let g:signify_sign_add = '+'
let g:signify_sign_change = '~'
let g:signify_sign_delete = '_'
let g:signify_sign_delete_first_line = '‾'

"nerdcommenter
let g:NERDSpaceDelims = 1

"vim-tagbar
map <f2> :TagbarToggle<CR>
let g:tagbar_iconchars = ['▸','▾']
highlight! link TagbarVisibilityPublic diffAdded
highlight! link TagbarVisibilityProtected Type
highlight! link TagbarVisibilityPrivate Special
highlight! link TagbarSignature Comment
let g:tagbar_type_tex = {
    \ 'ctagstype' : 'latex',
    \ 'kinds'     : [
        \ 's:sections:0:0',
        \ 'g:graphics:1:0',
        \ 'l:labels:1:0',
        \ 'r:refs:1:0',
        \ 'p:pagerefs:1:0'
    \ ],
    \ 'sort'    : 0,
    \ 'kind2scope': {},
    \ 'scope2kind': {},
\ }

"treat SConstruct/SConscript as python
autocmd BufReadPre SCons* set filetype=python
autocmd BufNewFile SCons* set filetype=python

"remove trailing whitespace from most files
autocmd Filetype python,cpp,tex,vim autocmd BufWritePre  * exec "norm m`" | %s/\s\+$//e | exec "norm ``"
autocmd Filetype python,cpp,tex,vim autocmd FileWritePre * exec "norm m`" | '[,']s/\s\+$//e | exec "norm ``"

" Starting with Vim 7, the filetype of empty .tex files defaults to
" 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
" The following changes the default filetype back to 'tex':
let g:tex_flavor='latex'

" let syntastic do the linting
let g:pymode_lint = 0
let g:pymode_lint_on_write = 0
let g:pymode_lint_unmodified = 0
let g:pymode_lint_on_fly = 0
let g:pymode_lint_message = 0
let g:pymode_lint_checkers = []
" don't fold python code on open
let g:pymode_folding = 0
" don't load rope by default. Change to 1 to use rope
let g:pymode_rope=0
let g:pymode_rope_regenerate_on_write=0

"Remove useless print button
if has("gui_running")
    aunmenu ToolBar.Print
endif

"Don't print but open file in evince for preview
set printexpr=PrintFile(v:fname_in)
function! PrintFile(fname)
  call system("mv " . a:fname . ' ' . a:fname . '.ps')
  call system("evince " . a:fname . '.ps; rm ' . a:fname . '.ps &')
 " call delete(a:fname . '.ps')
  return v:shell_error
endfunc

function! ListFiles()
python3 << EOF
import vim
files = []
for b in vim.buffers:
    if b.name is not None:
        files.append(b.name)
vim.command("return \"%s\"" % "\n".join(files))
EOF
endfunc

function! Highlight(line)
  :execute 'match Search /\%'.a:line.'l/'
  :call foreground()
endfunc
