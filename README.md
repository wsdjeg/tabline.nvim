# tabline.nvim

_tabline.nvim_ is a simple tabline plugin for Neovim.

[![GitHub License](https://img.shields.io/github/license/wsdjeg/tabline.nvim)](LICENSE)
[![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/wsdjeg/tabline.nvim)](https://github.com/wsdjeg/tabline.nvim/issues)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/m/wsdjeg/tabline.nvim)](https://github.com/wsdjeg/tabline.nvim/commits/master/)
[![GitHub Release](https://img.shields.io/github/v/release/wsdjeg/tabline.nvim)](https://github.com/wsdjeg/tabline.nvim/releases)

![Image](https://github.com/user-attachments/assets/4a6e39cb-0e16-4d29-be7a-3e3d4a4316cf)

<!-- vim-markdown-toc GFM -->

- [Install](#install)
- [Configuration](#configuration)
- [Highlight group](#highlight-group)
    - [Themes](#themes)
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
  -- # types, default is 4
  -- # 0: 1 ➛ ➊
  -- # 1: 1 ➛ ➀
  -- # 2: 1 ➛ ⓵
  -- # 3: 1 ➛ ¹
  -- # 4: 1 ➛ 1
  index_type = 4,
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

| Highlight      | description                                   |
| -------------- | --------------------------------------------- |
| TablineNvimA   | highlight of current buffer                   |
| TablineNvimB   | highlight of other buffer                     |
| TablineNvimM   | highlight of current buffer if it is modified |
| TablineNvimMNC | highlight of other buffer if it is modified   |

### Themes

| theme | colorscheme | file                         |
| ----- | ----------- | ---------------------------- |
| `one` | vim-one     | `lua/tabline/themes/one.lua` |

## Self-Promotion

Like this plugin? Star the repository on
GitHub.

Love this plugin? Follow [me](https://wsdjeg.net/) on
[GitHub](https://github.com/wsdjeg).

## Feedback

If you encounter any bugs or have suggestions, please file an issue in the [issue tracker](https://github.com/wsdjeg/tabline.nvim/issues)
