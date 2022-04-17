title: Vim 配置 
date: 2022-04-16
tags: [Linux, Vim]
categories: Linux
toc: true
---

# .vimrc

```
if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

syntax enable
"set background=light
"colorscheme solarized

let mapleader=","

""" Plugins  --------------------------------
" ys, cs, ds,  S
" set surround
" gcc, gc + motion, v_gc
" set commentary
" argument text objects: aa, ia
" set argtextobj
" cx{motion} to select, again to exchange
" set exchange
" entire buffer text object: ae
" set textobj-entire
" easymotion <Leader> s / f
" set easymotion
" 寄存器替换
" set ReplaceWithRegister
" 文件树展示
" set NERDTree
" 复制时高亮内容
" set highlightedyank
" 空格行也能够跳转
" set vim-paragraph-motion

" autocmd VimEnter * NERDTree

""" Common settings -------------------------
" 显示当前mode
set showmode
" 光标移动时保留5行
set so=5
" 实时查找
set incsearch
" 显示行号
" set nu
" 忽略大小写
set ignorecase
" 允许光标到行末
set virtualedit=onemore
" 搜索内容高亮显示
" set hlsearch
set tabstop=4
set shiftwidth=4
set expandtab

""" Plugin settings -------------------------
let g:argtextobj_pairs="[:],(:),<:>"
let g:highlightedyank_highlight_duration = "1000"
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

""" My Mappings -----------------------------
map <leader>f <Plug>(easymotion-sn)
map <leader>e <Plug>(easymotion-fn)
map <C-n> :NERDTreeToggle<CR>
```

# .vimrc.bundles
```
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-commentary'
Plugin 'vim-scripts/argtextobj.vim'
Plugin 'tommcdo/vim-exchange'
Plugin 'kana/vim-textobj-user'
Plugin 'kana/vim-textobj-entire'
Plugin 'easymotion/vim-easymotion'
Plugin 'vim-scripts/ReplaceWithRegister'
Plugin 'preservim/nerdtree'
Plugin 'machakann/vim-highlightedyank'
Plugin 'dbakker/vim-paragraph-motion'

call vundle#end()            " required
filetype plugin indent on    " required
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
```

# .ideavimrc
```
"" Source your .vimrc
source ~/.vimrc

"" -- Suggested options --
" Show a few lines of context around the cursor. Note that this makes the
" text scroll if you mouse-click near the start or end of the window.
set scrolloff=5

" Do incremental searching.
set incsearch

" Don't use Ex mode, use Q for formatting.
map Q gq


"" -- Map IDE actions to IdeaVim -- https://jb.gg/abva4t
"" Map \r to the Reformat Code action
"map \r <Action>(ReformatCode)

"" Map <leader>d to start debug
"map <leader>d <Action>(Debug)

"" Map \b to toggle the breakpoint on the current line
"map \b <Action>(ToggleLineBreakpoint)

let mapleader=','

" Find more examples here: https://jb.gg/share-ideavimrc

""" Plugins  --------------------------------
" ys, cs, ds,  S
set surround
" gcc, gc + motion, v_gc
set commentary
" argument text objects: aa, ia
set argtextobj
" cx{motion} to select, again to exchange
set exchange
" entire buffer text object: ae
set textobj-entire
" easymotion <Leader> s / f
set easymotion
" 寄存器替换
set ReplaceWithRegister
" 文件树展示
set NERDTree
" 复制时高亮内容
set highlightedyank
" 空格行也能够跳转
set vim-paragraph-motion


""" Common settings -------------------------
" 显示当前mode
set showmode
" 光标移动时保留5行
set so=5
" 实时查找
set incsearch
" 显示行号
set nu
" 忽略大小写
set ignorecase
" 允许光标到行末
set virtualedit=onemore
" 搜索内容高亮显示
set hlsearch

""" Idea specific settings ------------------
" 多行合并 J
set ideajoin
" icon展示
set ideastatusicon=gray
" 在normal mode默认eng
set keep-english-in-normal-and-restore-in-insert

""" Plugin settings -------------------------
let g:argtextobj_pairs="[:],(:),<:>"
let g:highlightedyank_highlight_duration = "1000"

""" My Mappings -----------------------------
map <leader>f <Plug>(easymotion-s)
map <leader>e <Plug>(easymotion-f)

map <leader>d <Action>(Debug)
map <leader>r <Action>(RenameElement)
map <leader>c <Action>(Stop)
map <leader>z <Action>(ToggleDistractionFreeMode)

map <leader>s <Action>(SelectInProjectView)
map <leader>a <Action>(Annotate)
map <leader>h <Action>(Vcs.ShowTabbedFileHistory)
map <S-Space> <Action>(GotoNextError)

map <leader>= <Action>(ReformatCode)

nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
inoremap <S-Tab> <C-D>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

set ideastrictmode
```
