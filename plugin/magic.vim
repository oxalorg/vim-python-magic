function! s:get_venv_package_dir()
    let l:venv_name = fnamemodify(getcwd(), ":t")
    return expand('~/.virtualenvs/'.l:venv_name.'/lib/python*/site-packages', 1)
endfunction

function! s:pytag_sink(line)
    let parts   = split(a:line, '\t\zs')
    let excmd   = matchstr(join(parts[2:-2], '')[:-2], '^.\{-}\ze;\?"')
    let base    = fnamemodify(parts[-1], ':h')
    let l:venv_name = fnamemodify(getcwd(), ":t")
    let l:venv_package_dir = s:get_venv_package_dir()
    let l:base = l:venv_package_dir
    let relpath = parts[1][:-2]
    let abspath = relpath =~ '^/' ? relpath : join([base, relpath], '/')
    execute 'edit' expand(abspath, 1)
    silent execute excmd
endfunction

function! s:pyimport_sink(line)
    let lnum = getcurpos()[1]
    let class = split(a:line, " ")[0]
    let cpath = substitute(split(a:line, " ")[1], "/", ".", "g")
    call append(0, printf("from %s import %s", cpath[:-4], class))
endfunction

function! s:py_source(env, strip_extra_columns)
    let l:venv_name = fnamemodify(getcwd(), ":t")
    let l:venv_tagfile = s:get_venv_package_dir().'/tags'
    let l:source = ""
    if a:env ==? "local"
        let l:source = 'cat '.join(map(tagfiles(), 'fnamemodify(v:val, ":S")')).' | grep "\.py"'
    elseif a:env ==? "venv"
        let l:source = 'cat '.l:venv_tagfile.' | grep "\.py"'
    else
        let l:source = 'cat '.join(map(tagfiles(), 'fnamemodify(v:val, ":S")')).' '.l:venv_tagfile.' | grep "\.py"'
    endif
    if a:strip_extra_columns == 1
        let l:source = printf("%s | awk '{print $1 \" \" $2}'", l:source)
    endif
    return l:source
endfunction

function! s:pytags(env)
    let l:source = s:py_source(a:env, 0)
    try
        call fzf#run(fzf#wrap({
        \ 'source':  l:source,
        \ 'options':  ['--nth', '1..2', '--prompt', 'JumpToPythonTag> '],
        \ 'sink':    function('s:pytag_sink')}))
    catch
        echohl WarningMsg
        echohl None
    endtry
endfunction

function! s:pyimport(env)
    let l:source = s:py_source(a:env, 1)
    try
        call fzf#run(fzf#wrap({
        \ 'source':  l:source,
        \ 'sink':    function('s:pyimport_sink')}))
    catch
        echohl WarningMsg
        echohl None
    endtry
endfunction

function! s:pytagsgen()
    let l:venv_name = fnamemodify(getcwd(), ":t")
    let l:venv_package_dir = s:get_venv_package_dir()
    let l:cmd = printf("cd %s && ctags --languages=Python --exclude=__pycache__ --exclude=_vendor -R .", l:venv_package_dir)
    call system(l:cmd)
    echom "Tags Generated for Venv: ".l:venv_name
endfunction

command! PyImportAll call s:pyimport('all')
command! PyImportLocal call s:pyimport('local')
command! PyImportVenv call s:pyimport('venv')
command! PyTagsVenv call s:pytags('venv')
command! PyTagsGenerate call s:pytagsgen()
