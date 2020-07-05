# vim-python-magic

This plugin serves 2 main purposes:

- Use fuzzy search to quickly import from local project + virtualenv
- Use fuzzy search to jump to any function/class/variable in virtualenv only
    - jumping to local tags is supported inbuilt by Fzf using `:Tags`

For both of these we are going to be taking advantage of ctags (exuberant ctags is recommended).

## Requirements

- Using virtualenvwrapper
    - `VIRTUALENV_DIR` should be set to `$HOME/.virtualenvs`
- Always opening vim instance from project root directory
    - This assumes your venv name is same as project root dir name
- FZF + fzf.vim installed
- Currently only tested on linux systems

## Install

```
Plug 'oxalorg/vim-python-magic'
```

## Usage

```
" Import from all tags (both local + venv)
nnoremap <leader>ii :PyImportAll<CR>

" Import from only local project tags
nnoremap <leader>il :PyImportLocal<CR>

" Import from only packages installed in your venv
nnoremap <leader>iv :PyImportVenv<CR>

" Jump to tags from packages installed in your venv
nnoremap <leader>tv :PyTagsVenv<CR>
```
