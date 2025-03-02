# tabline.nvim

`tabline.nvim` is a simple tabline plugin for Neovim.

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
```

## Highlight group

```
TablineNvimA
TablineNvimB
TablineNvimM
TablineNvimMNC
```
