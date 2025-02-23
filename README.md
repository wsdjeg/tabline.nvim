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

## Options


```lua
require('tabline').setup(
    {
        show_index = false, -- display index, disbale by default.
    }
)
```

## Highlight group

```
TablineNvimA
TablineNvimB
TablineNvimM
TablineNvimMNC
```
