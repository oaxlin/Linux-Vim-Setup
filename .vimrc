filetype plugin indent on

syntax on

set nocompatible

set ts=4
set sw=4

set expandtab

set showmatch " show matching brackets
set incsearch " Lookahead as search pattern is spedified
set ignorecase " Ignore case in all searches...
set smartcase " ... unless that search itself contains a cap
set hlsearch " Highlight all matches
set updatecount =20
silent set swapsync
nnoremap v <C-V>
nnoremap <C-V> v

" grab the whole word, not just part
nmap yw yaw

if isdirectory("/dev/shm")
    silent !mkdir /dev/shm/$USER\_vim > /dev/null 2>&1
    let &directory='/dev/shm/'.$USER.'_vim//'
    let &backupdir='/dev/shm/'.$USER.'_vim//'
else
    silent !mkdir /tmp/$USER\_vim > /dev/null 2>&1
    let &directory='/tmp/'.$USER.'_vim//'
    let &backupdir='/tmp/'.$USER.'_vim//'
endif

set wildmode=list:longest,full
set showcmd
set matchpairs+=<:>
set backspace=indent,eol,start
" matchit.vim
" CTRL-o go back through your jump history
" CTRL-i forward jump history
" CTRL-t add indentation before the line
" CTRL-V remove indentation
" * - search for all instances of the current word under the cursor
" :earlier 10m - what did my file look like 10 minutes ago
" :later 10m - move forward in time
" g+ g- go forward/backward in the undo buffer... even see old undo branches
"
" tab is a smart completion when in insert mode


nnoremap <Space> <PageDown> " Use spaces to jump down a page (like browsers do)...

augroup perl

    " check perl code with :make
    autocmd FileType perl set makeprg=perl\ -c\ %\ $*
    autocmd FileType perl set errorformat=%f:%l:%m
    autocmd FileType perl set autowrite

    " make lines longer than 120 characters errors (including newline)
    autocmd FileType perl match ErrorMsg /\%>119v.\+/

    " make tabs and trailing spaces errors
    autocmd FileType perl 2match ErrorMsg /[\t]\|\s\+\%#\@<!$/

augroup END

"bits from Damian Conway
"=====[ Make arrow keys move visual blocks around ]======================

vmap <up>    <Plug>SchleppUp
vmap <down>  <Plug>SchleppDown
vmap <left>  <Plug>SchleppLeft
vmap <right> <Plug>SchleppRight

vmap D       <Plug>SchleppDupLeft
vmap <C-D>   <Plug>SchleppDupLeft

"======[ Magically build interim directories if necessary ]===================
"

    function! AskQuit (msg, options, quit_option)
        if confirm(a:msg, a:options) == a:quit_option
            exit
        endif
    endfunction

    function! EnsureDirExists ()
        let required_dir = expand("%:h")
        if !isdirectory(required_dir)
            call AskQuit("Parent directory '" . required_dir . "' doesn't exist.",
                \       "&Create it\nor &Quit?", 2)

            try
                call mkdir( required_dir, 'p' )
            catch
                call AskQuit("Can't create '" . required_dir . "'",
                \            "&Quit\nor &Continue anyway?", 1)
            endtry
        endif
    endfunction

    augroup AutoMkdir
        autocmd!
        autocmd  BufNewFile  *  :call EnsureDirExists()
    augroup END


"====[ Mappings for eqalignsimple.vim (character-based alignments) ]===========

    " Align contiguous lines at the same indent...
    nmap <silent> =     :call CharAlign('nmap')<CR>
    nmap <silent> +     :call CharAlign('nmap', {'cursor':1} )<CR>

    " Align continuous lines in the same paragraph...
    nmap <silent> ==    :call CharAlign('nmap', {'paragraph':1} )<CR>
    nmap <silent> ++    :call CharAlign('nmap', {'cursor':1, 'paragraph':1} )<CR>

    " Align continuous lines in the current visual block
    vmap <silent> =     :call CharAlign('vmap')<CR>
    vmap <silent> +     :call CharAlign('vmap', {'cursor':1} )<CR>

" =====[ Smart completion via <TAB> and <S-TAB> ]=============

runtime plugin/smartcom.vim

" Add extra completions (mainly for Perl programming)...

let ANYTHING = ""
let NOTHING  = ""
let EOL      = '\s*$'

                " Left     Right      Insert                             Reset cursor
                " =====    =====      ===============================    ============
call SmartcomAdd( '<<',    ANYTHING,  '>>',                              {'restore':1} )
call SmartcomAdd( '<<',    '>>',      "\<CR>\<ESC>O\<TAB>"                             )
call SmartcomAdd( '?',     ANYTHING,  '?',                               {'restore':1} )
call SmartcomAdd( '?',     '?',       "\<CR>\<ESC>O\<TAB>"                             )
call SmartcomAdd( '{{',    ANYTHING,  '}}',                              {'restore':1} )
call SmartcomAdd( '{{',    '}}',      NOTHING,                                         )
call SmartcomAdd( 'qr{',   ANYTHING,  '}xms',                            {'restore':1} )
call SmartcomAdd( 'qr{',   '}xms',    "\<CR>\<C-D>\<ESC>O\<C-D>\<TAB>"                 )
call SmartcomAdd( 'm{',    ANYTHING,  '}xms',                            {'restore':1} )
call SmartcomAdd( 'm{',    '}xms',    "\<CR>\<C-D>\<ESC>O\<C-D>\<TAB>",                )
call SmartcomAdd( 's{',    ANYTHING,  '}{}xms',                          {'restore':1} )
call SmartcomAdd( 's{',    '}{}xms',  "\<CR>\<C-D>\<ESC>O\<C-D>\<TAB>",                )
call SmartcomAdd( '\*\*',  ANYTHING,  '**',                              {'restore':1} )
call SmartcomAdd( '\*\*',  '\*\*',    NOTHING,                                         )

" Handle single : correctly...
call SmartcomAdd( '^:\|[^:]:',  EOL,  "\<TAB>" )

"After an alignable, align...
function! AlignOnPat (pat)
    return "\<ESC>:call EQAS_Align('nmap',{'pattern':'" . a:pat . "'})\<CR>A"
endfunction
                " Left         Right        Insert
                " ==========   =====        =============================
call SmartcomAdd( '=',         ANYTHING,    "\<ESC>:call EQAS_Align('nmap')\<CR>A")
call SmartcomAdd( '=>',        ANYTHING,    AlignOnPat('=>') )
call SmartcomAdd( '\s#',       ANYTHING,    AlignOnPat('\%(\S\s*\)\@<= #') )
call SmartcomAdd( '[''"]\s*:', ANYTHING,    AlignOnPat(':'),                   {'filetype':'vim'} )
call SmartcomAdd( ':',         ANYTHING,    "\<TAB>",                          {'filetype':'vim'} )


" Perl keywords...
"
                " Left         Right   Insert                                  Where
                " ==========   =====   =============================           ===================
call SmartcomAdd( '^\s*for',   EOL,    " my $___ (___) {\n___\n}\n___",        {'filetype':'perl'} )
call SmartcomAdd( '^\s*if',    EOL,    " (___) {\n___\n}\n___",                {'filetype':'perl'} )
call SmartcomAdd( '^\s*while', EOL,    " (___) {\n___\n}\n___",                {'filetype':'perl'} )
call SmartcomAdd( '^\s*given', EOL,    " (___) {\n___\n}\n___",                {'filetype':'perl'} )
call SmartcomAdd( '^\s*when',  EOL,    " (___) {\n___\n}\n___",                {'filetype':'perl'} )

"=====[ Search folding ]=====================

    " Toggle on and off...
    nmap <silent> <expr>  zz  FS_ToggleFoldAroundSearch({'context':1})

    " Show only sub defns (and maybe comments)...
    let perl_sub_pat = '^\s*\%(sub\|func\|method\)\s\+\k\+'
    let vim_sub_pat  = '^\s*fu\%[nction!]\s\+\k\+'
    augroup FoldSub
        autocmd!
        autocmd BufEnter * nmap <silent> <expr>  zp  FS_FoldAroundTarget(perl_sub_pat,{'context':1})
        autocmd BufEnter * nmap <silent> <expr>  za  FS_FoldAroundTarget(perl_sub_pat.'\\|^\s*#.*',{'context':0, 'folds':'invisible'})
        autocmd BufEnter *.vim,.vimrc nmap <silent> <expr>  zp  FS_FoldAroundTarget(vim_sub_pat,{'context':1})
        autocmd BufEnter *.vim,.vimrc nmap <silent> <expr>  za  FS_FoldAroundTarget(vim_sub_pat.'\\|^\s*".*',{'context':0, 'folds':'invisible'})
    augroup END

    " Show only C #includes...
    nmap <silent> <expr>  zu  FS_FoldAroundTarget('^\s*use\s\+\S.*;',{'context':1})


"====[ Emphasize undereferenced references ]=====================

    highlight WHITE_ON_RED    ctermfg=white  ctermbg=red
    call matchadd('WHITE_ON_RED', '_ref'.'[ ]*[[{(]\|_ref'.'[ ]*-[^>]')


"====[ Emphasize typical mistakes a Perl hacker makes in .vim files ]=========

    let g:VimMistakes
        \= '\_^\s*\zs\%(my\s\+\)\?\%(\k:\)\?\k\+\%(\[.\{-}\]\)\?\s*[+-.]\?==\@!'
        \. '\|\_^\s*elsif'
        \. '\|;\s*\_$'
        \. '\|\_^\s*#.*'

    augroup VimMistakes
        autocmd!
        autocmd BufEnter  *.vim,.vimrc   call VimMistakes_AddMatch()
        autocmd BufLeave  *.vim,.vimrc   call VimMistakes_ClearMatch()
    augroup END

    let g:VimMistakesID = 668
    function! VimMistakes_AddMatch ()
        try | call matchadd('WHITE_ON_RED',g:VimMistakes,10,g:VimMistakesID) | catch | endtry
    endfunction

    function! VimMistakes_ClearMatch ()
        try | call matchdelete(g:VimMistakesID) | catch | endtry
    endfunction


"=====[ Perl folding ]=====================

nmap <silent> zp /^\s*sub\s\+\w\+<CR>
                \:nohlsearch<CR>
                \``
                \zz
                \:call SetZPHighlight()<CR>

function! SetZPHighlight ()
    if exists('b:ZPHighlightID')
        call matchdelete(b:ZPHighlightID)
        unlet b:ZPHighlightID
    endif
    if &foldlevel == 0
        let b:ZPHighlightID = matchadd('WHITE_ON_BLACK','^\s*sub\s\+\w\+')
    endif
endfunction

"=====[ Correct common mistypings in-the-fly ]=======================

iab        ,,  =>
iab    retrun  return
iab     pritn  print
iab       teh  the
iab      liek  like
iab  liekwise  likewise
iab      Pelr  Perl
iab      pelr  perl
iab        ;t  't
iab    Jarrko  Jarkko
iab    jarrko  jarkko
iab      moer  more
iab  previosu  previous
