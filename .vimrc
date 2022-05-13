" Gutter
set relativenumber


" Misc
set hlsearch
set nowrapscan      " don't wrap searches beyond end of file
set laststatus=2    " always show a statusline on "last window"
set scrolloff=2     " min number of lines to show before and after the cursor when scrolling
set encoding=utf-8  " default encoding
set synmaxcol=120   " max columns to do syntax parsing for on a line (smaller number = faster redraw)


" Tabs
set autoindent
set expandtab       " use spaces for indentation in insert mode, autoindent, and when using '>' and '<'
set tabstop=4       " number of spaces that a <tab> in the file counts for
set shiftwidth=4    " number of spaces to use for each step of (auto)indent, used for '<<', '>>', etc..
set softtabstop=4   " number of spaces that a <tab> counts for while performing editing operations


" Enhanced tab completion
set wildmenu
set wildmode=list:longest


" Highlight unwanted whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()


" Function to remove trailing whitespace
command! Rtrim call s:rtrim()
function! s:rtrim()
  %s/\s\+$//g
endfunction

" Function to swap to second choice colorscheme
command! Co call s:SwapColors()
function! s:SwapColors()
  set notermguicolors
  colorscheme slate
endfunction

function! s:main_setup()
  " Download plugins
  let s:plugins = {
    \'git': {
      \'pack/shames0/opt': [
        \'https://github.com/editorconfig/editorconfig-vim',
        \'https://github.com/tpope/vim-fugitive',
        \'https://github.com/nathanaelkane/vim-indent-guides',
        \'https://github.com/sainnhe/everforest',
      \],
    \},
    \'curl': {
      \'pack/shames0/start/prefs/autoload': [
        \'https://raw.githubusercontent.com/klp2/dc_eqalignssimple/master/plugin/eqalignsimple.vim',
        \'https://raw.githubusercontent.com/shames0/my-vim-config/master/.vim/prefs/editorconfig.vim',
        \'https://raw.githubusercontent.com/shames0/my-vim-config/master/.vim/prefs/indent_guides.vim',
      \],
    \},
  \}
  call s:ensure_installed(s:plugins)


  " Syntax highlighting
  syntax enable


  if has('termguicolors')
    "" configurations for my first-choice colorscheme
    set termguicolors     " enable 'true color'

    "" These are required to allow guicolors to work within tmux and screen
    "  (My understanding is that these are auto-loaded by vim if TERM is
    "  xterm, but they have to be forced otherwise)
    let &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
    let &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"

    packadd! everforest   " import desired colorscheme from .vim/pack/shames0/opt
    set background=dark

    let g:everforest_background = 'hard'
    let g:everforest_enable_italic = 0
    let g:everforest_disable_italic_comment = 1

    colorscheme everforest
  else
    colorscheme slate
  endif
endfunction


" Function to download wanted plugins
function! s:ensure_installed(plugins)
  for download_method in keys(a:plugins)
    for dest_folder in keys(a:plugins[download_method])
      let l:dest_path = join([ $HOME, '.vim', dest_folder], '/')

      for source_url in a:plugins[download_method][dest_folder]
        " Get the 'basename' of the source url, and make that our destination filename.
        let l:dest_name = join([l:dest_path, fnamemodify(source_url, ':t')], '/')

        if empty(glob(l:dest_name))
          " If the destination doesn't exist, pull it down
          echon "Downloading missing plugins...\n"

          let l:print_meth = download_method ==# 'git' ? 'cloning' : 'downloading'
          execute 'silent !echo -e "'. l:print_meth .' '. source_url .' => '. l:dest_name . '"'

          if download_method ==# 'git'
            execute join (['silent !git clone -q', source_url, l:dest_name], ' ')
          elseif download_method ==# 'curl'
            execute join (['silent !curl --create-dirs -sSfLo', l:dest_name, source_url], ' ')
          else
            echo join(['Unknown download method:', download_method], ' ')
          endif
        endif
      endfor

    endfor
  endfor
endfunction

call s:main_setup()
