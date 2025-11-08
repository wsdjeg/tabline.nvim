# tabline.nvim

`tabline.nvim` is a simple tabline plugin for Neovim.

![Image](https://github.com/user-attachments/assets/4a6e39cb-0e16-4d29-be7a-3e3d4a4316cf)


<!-- vim-markdown-toc GFM -->

- [Install](#install)
- [Configuration](#configuration)
- [Highlight group](#highlight-group)
- [Self-Promotion](#self-promotion)
- [Feedback](#feedback)

<!-- vim-markdown-toc -->

## Install

With [nvim-plug](https://github.com/wsdjeg/nvim-plug):

```lua
require('plug').add({
    {
        'wsdjeg/tabline.nvim',
        config = function()
            require('tabline').setup()
        end
    }
})
```

## Configuration

```lua
require('tabline').setup({
  show_index = false, -- display index, disbale by default.
})

-- use leader + number for buffer jump
for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, function()
    require('tabline').jump(i)
  end, { silent = true })
end

-- use alt-left/right to move buffer
vim.keymap.set('n', '<A-Left>' .. i, function()
  require('tabline').move_to_previous()
end, { silent = true })
vim.keymap.set('n', '<A-Right>' .. i, function()
  require('tabline').move_to_next()
end, { silent = true })
```

## Highlight group

```
TablineNvimA
TablineNvimB
TablineNvimM
TablineNvimMNC
```

## Self-Promotion

Like this plugin? Star the repository on
GitHub.

Love this plugin? Follow [me](https://wsdjeg.net/) on
[GitHub](https://github.com/wsdjeg).

## Feedback

If you encounter any bugs or have suggestions, please file an issue in the [issue tracker](https://github.com/wsdjeg/tabline.nvim/issues)
