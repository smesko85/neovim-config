set pumheight=15                                                                "Maximum number of entries in autocomplete popup

augroup vimrc_autocomplete
  autocmd!
  autocmd VimEnter * lua require'lsp_setup'
  autocmd FileType javascript,javascriptreact,vim,php,gopls,lua setlocal omnifunc=v:lua.omnifunc_sync
augroup END

set completeopt=menuone,noinsert,noselect

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

function s:tab_completion() abort
  if vsnip#jumpable(1)
    return "\<Plug>(vsnip-jump-next)"
  endif

  if pumvisible()
    return "\<C-n>"
  endif

  if s:check_back_space()
    return "\<TAB>"
  endif

  if vsnip#expandable()
    return "\<Plug>(vsnip-expand)"
  endif

  if !empty(&omnifunc)
    return "\<C-x>\<C-o>"
  endif

  return "\<C-n>"
endfunction

imap <expr> <TAB> <sid>tab_completion()
imap <expr><C-space> "\<C-r>=CustomPathCompletion()\<CR>"

imap <expr><S-TAB> pumvisible() ? "\<C-p>" : vsnip#jumpable(-1) ? "\<Plug>(vsnip-jump-prev)" : "\<S-TAB>"
smap <expr><TAB> vsnip#available(1)  ? "\<Plug>(vsnip-expand-or-jump)" : "\<TAB>"
smap <expr><S-TAB> vsnip#available(-1)  ? "\<Plug>(vsnip-jump-prev)" : "\<S-TAB>"
imap <expr> <CR> vsnip#expandable() ? "\<Plug>(vsnip-expand)" : "\<Plug>(PearTreeExpand)"

nmap <leader>ld <cmd>lua vim.lsp.buf.definition()<CR>
nmap <leader>lc <cmd>lua vim.lsp.buf.declaration()<CR>
nmap <leader>lg <cmd>lua vim.lsp.buf.implementation()<CR>
nmap <leader>lu <cmd>lua vim.lsp.buf.references()<CR>
nmap <leader>lr <cmd>lua vim.lsp.buf.rename()<CR>
nmap <leader>lh <cmd>lua vim.lsp.buf.hover()<CR>
nmap <leader>lf <cmd>lua vim.lsp.buf.formatting()<CR>
vmap <leader>lf :<C-u>call v:lua.vim.lsp.buf.range_formatting()<CR>
nmap <leader>la :call v:lua.vim.lsp.buf.code_action()<CR>
vmap <leader>la :<C-u>call v:lua.vim.lsp.buf.range_code_action()<CR>
nmap <leader>li <cmd>lua vim.lsp.buf.incoming_calls()<CR>
nmap <leader>lo <cmd>lua vim.lsp.buf.outgoing_calls()<CR>
nmap <leader>le <cmd>lua vim.lsp.util.show_line_diagnostics()<CR>
nmap <leader>lt <cmd>lua vim.lsp.buf.document_symbol()<CR>
nmap <leader>lT <cmd>lua vim.lsp.buf.workspace_symbol()<CR>

set wildoptions=pum
set wildignore=*.o,*.obj,*~                                                     "stuff to ignore when tab completing
set wildignore+=*.git*
set wildignore+=*.meteor*
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=*mypy_cache*
set wildignore+=*__pycache__*
set wildignore+=*cache*
set wildignore+=*logs*
set wildignore+=*node_modules*
set wildignore+=**/node_modules/**
set wildignore+=*DS_Store*
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif


fun! s:fnameescape(p)
  return escape(fnameescape(a:p), '}')
endf

" Taken from mucomplete
" https://github.com/lifepillar/vim-mucomplete/blob/master/autoload/mucomplete/path.vim#L78
function! CustomPathCompletion() abort
  let l:prefix = matchstr(getline('.'), '\f\%(\f\|\s\)*\%'.col('.').'c')
  while strlen(l:prefix) > 0 " Try to find an existing path (consider paths with spaces, too)
    if l:prefix ==# '~'
      let l:files = glob('~', 0, 1, 1)
      if !empty(l:files)
        call complete(col('.') - 1, map(l:files, '{ "word": v:val, "menu": "[dir]" }'))
        return ''
      endif
      return feedkeys("\<C-g>\<C-g>\<C-n>")
    endif

    let l:files = glob(
          \ (l:prefix !~# '^[/~]'
          \   ? s:fnameescape(expand('%:p:h')) . '/'
          \   : '')
          \ . s:fnameescape(l:prefix) . '*', 0, 1, 1)
    if !empty(l:files)
      call complete(col('.') - len(fnamemodify(l:prefix, ':t')), map(l:files,
            \  '{
            \      "word": fnamemodify(v:val, ":t"),
            \      "menu": (isdirectory(v:val) ? "[dir]" : "[file]"),
            \   }'
            \ ))
      return ''
    endif
    let l:prefix = matchstr(l:prefix, '\%(\s\|=\)\zs.*[/~].*$', 1) " Next potential path
  endwhile
  return feedkeys("\<C-g>\<C-g>\<C-n>")
endfunction
