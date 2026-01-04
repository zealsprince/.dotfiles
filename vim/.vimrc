
" Neko Vim configuration https://github.com/catlinman/neko-config/vim/

" Required settings.
set nocompatible
filetype off

" ###    GENERAL VIM-PLUG INFORMATION     ###
"
" Install vim-plug before doing anything else.
"
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"
" Once you have installed vim-plug you can run:
" vim +PlugInstall +qall
"
" Alternatively, inside Vim:
" :PlugInstall
"
" ###                                     ###

" Skip initialization for vim-tiny or vim-small.
if 0 | endif
if &compatible
    set nocompatible
endif

" Begin vim-plug plugin block.
call plug#begin('~/.vim/plugged')

" Autoswap sessions on detection of leftover swp file.
Plug 'gioele/vim-autoswap'

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Airline requires the powerline fonts to be installed and activated.
" Ignore this if we are running on just the linux kernal terminal.
if $TERM != "linux"
    Plug 'Lokaltog/powerline-fonts'
endif

" Color scheme
Plug 'chriskempson/base16-vim'

" Navigation and highlighting (Implements 'TagbarToggle')
Plug 'Lokaltog/vim-easymotion'
Plug 'kien/ctrlp.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'ap/vim-css-color'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'majutsushi/tagbar'

" Colorizer color highlighting (Implements 'ColorHighlight')
Plug 'chrisbra/Colorizer'

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Formatting & Linting (Implements 'ALEToggle')
Plug 'dhruvasagar/vim-table-mode'
Plug 'Chiel92/vim-autoformat'
Plug 'w0rp/ale'

" Snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" Languages
Plug 'rust-lang/rust.vim'
Plug 'tmux-plugins/vim-tmux'

" Python dependent plugins (Implements 'MinimapToggle')
if has("python") || has("python3")
    Plug 'severin-lemaignan/vim-minimap'
    Plug 'Valloric/MatchTagAlways'
endif

call plug#end()

" Required setting.
filetype plugin indent on

" Brief help
" :PlugInstall   - installs plugins
" :PlugUpdate    - updates plugins
" :PlugClean     - removes unused plugins
" :PlugStatus    - checks plugin status
"
" see :h plug for more details
" Put your non-plugin stuff after this line

" Set the Base16 color scheme. Make sure that Base16 Shell is installed.
syntax on
set t_Co=256
let base16colorspace=256

" Load the default color scheme so some plugins don't break.
colorscheme default

if $TERM != 'linux'
    colorscheme base16-neko

endif

" Set the correct background.
set background=dark

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

inoremap jk <ESC>
inoremap kj <ESC>

" Add mouse support.
set mouse=a

" Use soft tabs with width of 4 spaces.
set tabstop=4
set expandtab
set shiftwidth=4
set autoindent
set softtabstop=4
set ts=4 sw=4
set cursorline

" Change backspace behavior.
set backspace=indent,eol,start

" Enable highlighted searching. Press space to disable highlighting.
set hlsearch
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" Set the timeout length of entering normal mode.
set ttimeoutlen=50

" Set encoding options.
set encoding=utf-8
set termencoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936

" Line numbers.
set number
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE

" Set a key for toggling line numbers on and off.
nnoremap <silent> <F2> :set number!<CR>

" Set a key for toggling relative line numbers.
nnoremap <silent> <F3> :set relativenumber!<CR>
hi CursorLineNr cterm=NONE ctermbg=NONE ctermfg=yellow

" Set a key for toggling easier navigation highlighting.
nnoremap <silent> <F4> :set cursorline!<CR>
nnoremap <silent> <F5> :set cursorcolumn!<CR>

" Coloring for cursor lines.
hi CursorLine   cterm=NONE ctermbg=234 ctermfg=NONE
hi CursorColumn cterm=NONE ctermbg=234 ctermfg=NONE

" Enable keeping the last status open.
set laststatus=2

filetype indent plugin on

let g:pymode_python='python3'

let g:mta_filetypes={
    \ 'html' : 1,
    \ 'xhtml' : 1,
    \ 'xml' : 1,
    \ 'jinja' : 1,
    \ 'php' : 1,
    \}

highlight Pmenu ctermfg=blue ctermbg=black

" Colorizer configuration.
let g:colorizer_auto_filetype='css,html,less,scss,sass,txt,md,vue,j2'
let g:colorizer_skip_comments=1

" gVim configuration.
if has('gui_running')
    map <F11> <Esc>:call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)<CR>y

    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar

    if has('gui_win32')
        set guifont=Inconsolata_for_Powerline:h9:cANSI

    else
        set guifont=Inconsolata\ for\ Powerline\ 9

    endif

endif

" Airline configuration.
if !exists('g:airline_symbols')
    let g:airline_symbols={}
endif

if $TERM == 'linux'
    let g:airline_left_sep='|'
    let g:airline_left_alt_sep='|'
    let g:airline_right_sep='|'
    let g:airline_right_alt_sep='|'
    let g:airline_theme='luna'

else
    let g:airline_powerline_fonts=1
    let g:airline#extensions#tabline#enabled=1
    let g:airline_theme='wombat'

endif

" Indent guide configuration.
let g:indent_guides_auto_colors=0
let g:indent_guides_guide_size=1
let g:indent_guides_color_change_percent=0
let g:indent_guides_enable_on_vim_startup=1
let g:indent_guides_start_level=2

" Indent guide colors.
hi IndentGuidesOdd  ctermbg=black
hi IndentGuidesEven ctermbg=black

" Snippet configuration.
let g:UltiSnipsExpandTrigger='<tab>'
let g:UltiSnipsJumpForwardTrigger='<c-b>'
let g:UltiSnipsJumpBackwardTrigger='<c-z>'
