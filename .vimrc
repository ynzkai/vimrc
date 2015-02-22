syntax on
filetype plugin indent on

autocmd FileType text setlocal textwidth=78

"enable pathogen plugin
execute pathogen#infect()

"************************************
autocmd vimenter * if !argc() | NERDTree | endif
map <C-n> :NERDTreeToggle<CR>
"************************************

"************************************
"function! Highlight_cursor ()
"    set cursorline
"    redraw
"    sleep 1
"    set nocursorline
"endfunction
"
"function! Autosave ()
"   if &modified && g:autosave_on_focus_change
"       write
"       echo "Autosaved file while you were absent" 
"   endif
"endfunction
"
"autocmd FocusGained * call Highlight_cursor()
"autocmd FocusLost * call Autosave() 
"************************************

set nocompatible
set nobackup
set nu
set incsearch
set hlsearch
set backspace=indent,eol,start
set history=50
set ruler
set showcmd
set nowrap
"set cul
"set t_Co=256
"set laststatus=2
set ttimeoutlen=50

set pastetoggle=<F2>


set autoindent
set smartindent
set cindent
set smarttab
set scrolloff=3
set tabstop=4
set softtabstop=4
set shiftwidth=4
autocmd FileType ruby setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType html setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType *.erb setlocal tabstop=2 shiftwidth=2 expandtab

"set listchars=tab:>-,eol:<,trail:_
"set list

let mapleader=","
map <leader>( bi(<Esc>ea)<Esc>
map <leader>{ bi{<Esc>ea}<Esc>
map <leader>" bi"<Esc>ea"<Esc>
map <S-l> :bnext<CR>
map <S-h> :bpre<CR>
nmap <C-Left> <C-w><
nmap <C-Right> <C-w>>
nmap <C-up> <C-w>-
nmap <C-down> <C-w>+

map <F5> :!g++ -o %:t:r %:t<CR>:!%:p:r<CR>

" This is the way I like my quotation marks and various braces
inoremap '' ''<Left>
inoremap "" ""<Left>
inoremap () ()<Left>
inoremap <> <><Left>
inoremap {} {}<Left>
inoremap [] []<Left>

" Quickly set comma or semicolon at the end of the string
inoremap ,, <End>,
inoremap ;; <End>;

inoremap <C-cr> <Esc>o{<CR>}<Esc>O
inoremap '<CR> <End><space>{<CR>}<Esc>O
imap <C-j> <Esc>o
imap <C-k> <Esc>O
imap <C-h> <Left>
imap <C-l> <Right>

nmap <C-l> <C-w>l
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k


"{{{test
"inoremap <expr> <C-L> ListItem()
"inoremap <expr> <C-R> ListReset()
"
"func ListItem()
"	if !exists("b:counter")
"		let b:counter = 0
"	endif
"	let b:counter += 1
"	return b:counter . '. '
"endfunc
"
"func ListReset()
"	if !exists("b:counter")
"		let b:counter = 0
"	endif
"	let b:counter = 0
"	return ''
"endfunc
"}}}


nmap <silent>  ;=  :call AlignAssignments()<CR>
function! AlignAssignments ()
    " Patterns needed to locate assignment operators...
    let ASSIGN_OP   = '[-+*/%|&]\?=\@<!=[=~]\@!'
    let ASSIGN_LINE = '^\(.\{-}\)\s*\(' . ASSIGN_OP . '\)\(.*\)$'

    " Locate block of code to be considered (same indentation, no blanks)
    let indent_pat = '^' . matchstr(getline('.'), '^\s*') . '\S'
    let firstline  = search('^\%('. indent_pat . '\)\@!','bnW') + 1
    let lastline   = search('^\%('. indent_pat . '\)\@!', 'nW') - 1
    if lastline < 0
        let lastline = line('$')
    endif

    " Decompose lines at assignment operators...
    let lines = []
    for linetext in getline(firstline, lastline)
        let fields = matchlist(linetext, ASSIGN_LINE)
        call add(lines, fields[1:3])
    endfor

    " Determine maximal lengths of lvalue and operator...
    let op_lines = filter(copy(lines),'!empty(v:val)')
    let max_lval = max( map(copy(op_lines), 'strlen(v:val[0])') ) + 1
    let max_op   = max( map(copy(op_lines), 'strlen(v:val[1])'  ) )

    " Recompose lines with operators at the maximum length...
    let linenum = firstline
    for line in lines
        if !empty(line)
            let newline
            \    = printf("%-*s%*s%s", max_lval, line[0], max_op, line[1], line[2])
            call setline(linenum, newline)
        endif
        let linenum += 1
    endfor
endfunction

" auto close html tag
function! CloseTag()
	let current_line = getline('.')
	let lnum = line('.')

	" find '<' pos
	normal F<
	let acol = col('.')

	" find space pos
	let scol = match(current_line, ' ', acol) + 1

	" find '>' pos
	if current_line[col('.')] == '>'
		let bcol = getpos('.')
		" save close tag pos
		let ecol = bcol
	else
		normal f>
		let bcol = col('.')
		" save close tag pos
		let ecol = bcol
	endif

	" get tag start and end pos
	if scol != 0 && scol < bcol
		let bcol = scol
	endif

	if acol && bcol
		let tag = strpart(current_line, acol, bcol-acol-1)
		let newline = strpart(current_line, 0, ecol) . '</' . tag . '>' . strpart(current_line, ecol)
		call setline(lnum, newline)
	endif
endfunction

" set hotkeys of CloseTag function
autocmd FileType html imap <silent> <leader><Tab> <esc>:call CloseTag()<cr>a
autocmd FileType html imap <silent> <leader><cr> <esc>:call CloseTag()<cr>a<cr><c-k>
autocmd FileType erb imap <silent> <leader><Tab> <esc>:call CloseTag()<cr>a
autocmd FileType erb imap <silent> <leader><cr> <esc>:call CloseTag()<cr>a<cr><c-k>
