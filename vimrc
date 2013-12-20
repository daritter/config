"Run only once
if exists("homevimrc_loaded")
    finish
endif
let homevimrc_loaded = 1

" Make vim work with the belle2 python version. The problem is that the
" virtualenv does not work for programs linked against libpython as not all
" paths are corrected. This nasty piece of code will replace the sys.prefix
" with the VIRTUAL_ENV prefix and also replace all paths in sys.path which
" seem to be in prefix to point to the VIRTUAL_ENV prefix.
"
" Not sure this will work in all cases but it got YouCompleteMe to cooperate
" so I am hopeful
python <<EOF
import os
import sys
if os.environ.has_key("BELLE2_TOOLS"):
    new_prefix = os.environ["VIRTUAL_ENV"]
    sys.real_prefix = sys.prefix
    sys.real_path = sys.path[:]
    for i,path in enumerate(sys.path):
        if path.startswith(sys.prefix):
            new_path = os.path.join(new_prefix, path[len(sys.prefix)+1:])
            if os.path.exists(new_path):
                sys.path[i] = new_path

    sys.prefix = new_prefix
EOF

" Setting up Vundle - the vim plugin bundler
set nocompatible              " be iMproved
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
Bundle 'altercation/vim-colors-solarized'
Bundle 'bling/vim-airline'
Bundle 'tpope/vim-fugitive'
Bundle 'mhinz/vim-signify'
Bundle 'git://git.code.sf.net/p/vim-latex/vim-latex'
Bundle 'Valloric/YouCompleteMe'
Bundle 'klen/python-mode'
Bundle 'python.vim'
Bundle 'python_match.vim'
Bundle 'pythoncomplete'
Bundle 'majutsushi/tagbar'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'perdirvimrc--Autoload-vimrc-files-per-di'
if iCanHazVundle == 0
    echo "Installing Bundles, please ignore key map error messages"
    echo ""
    :BundleInstall
endif
" Setting up Vundle - the vim plugin bundler end

" Configuration file for vim
set encoding=utf-8
au GUIEnter * set columns=117 lines=40
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
set diffopt+=iwhite
set wildmenu wildmode=longest,list
set autoindent expandtab shiftwidth=4 softtabstop=4
" Suffixes that get lower priority when doing tab completion for filenames.
" These are files we are not likely to want to edit or read.
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc

if isdirectory("/mnt/scratch/tmp")
    set directory=/mnt/scratch/tmp/ritter//
    if !isdirectory("/mnt/scratch/tmp/ritter")
        call mkdir("/mnt/scratch/tmp/ritter", "p")
    endif
else
    set dir=~/.vim/tmp//	" Put swapfiles in vim dir
endif

filetype plugin indent on
syntax on

"syntastic
let g:syntastic_check_on_open = 1
let g:syntastic_enable_signs = 1
let g:syntastic_enable_balloons = 1
let g:syntastic_enable_highlighting = 1
let g:syntastic_id_checkers = 1
let g:syntastic_python_checkers = ['python', 'pyflakes', 'pep8']
let g:syntastic_error_symbol = "\ue0b0\ue0b1"
let g:syntastic_warning_symbol = "\ue0b0\ue0b1"
let g:syntastic_style_error_symbol = "\ue0b1\ue0b1"
let g:syntastic_style_warning_symbol = "\ue0b1\ue0b1"

"YouCompleteME
let g:ycm_global_ycm_extra_conf = '~/.vim/ycm_conf.py'
let g:ycm_extra_conf_globlist = [resolve(expand('~/basf2/')) . '*']
"let g:ycm_extra_conf_vim_data = ['b:syntastic_cpp_cflags']

"vim airline
set t_Co=16
set laststatus=2 guifont=Ubuntu\ Mono\ derivative\ Powerline\ 13
"if has("gui_running")
let g:airline_theme='solarized'
set background=dark
let g:solarized_contrast='normal'
let g:solarized_termcolors=255
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
let g:signify_diffoptions = { 'git': '-w', 'hg': '-w' }
let g:signify_sign_add               = '+'
let g:signify_sign_change            = '~'
let g:signify_sign_delete            = '_'
let g:signify_sign_delete_first_line = '‾'

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

"Highlight extra whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
au ColorScheme * highlight ExtraWhitespace guibg=red
au BufEnter * match ExtraWhitespace /\s\+$/
au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
au InsertLeave * match ExtraWhiteSpace /\s\+$/
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
python << EOF
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
