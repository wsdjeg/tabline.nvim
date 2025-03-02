# tabline.nvim

`tabline.nvim` is a simple tabline plugin for Neovim.

![Image](https://github.com/user-attachments/assets/4a6e39cb-0e16-4d29-be7a-3e3d4a4316cf)

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
