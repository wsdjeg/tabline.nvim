--=============================================================================
-- tabline.lua --- tabline plugin implemented in lua
-- Copyright (c) 2016-2023 Wang Shidong & Contributors
-- Author: Wang Shidong < wsdjeg@outlook.com >
-- License: GPLv3
--=============================================================================

local M = {}

local devicon_hls = {}

-- https://github.com/ryanoasis/powerline-extra-symbols

local separators = {
  arrow = { '', '' },
  curve = { '', '' },
  slant = { '', '' },
  brace = { '', '' },
  fire = { '', '' },
  ['nil'] = { '', '' },
}

local i_separators = {
  arrow = { '', '' },
  curve = { '', '' },
  slant = { '', '' },
  bar = { '|', '|' },
  ['nil'] = { '', '' },
}

-- # types:
-- # 0: 1 ➛ ➊
-- # 1: 1 ➛ ➀
-- # 2: 1 ➛ ⓵
-- # 3: 1 ➛ ¹
-- # 4: 1 ➛ 1
local index_type = 4

local isep
local right_sep
local left_sep

local show_index = false

local util = require('tabline.util')

local shown_items = {}

local right_hide_bufs = {}

local visiable_bufs = {}

local left_hide_bufs = {}

local function check_len(bufs)
  local len = 0

  for _, v in ipairs(bufs) do
    local name = vim.fn.bufname(v)
    name = vim.fn.fnamemodify(name, ':t')
    len = len + #name + 6
    if len > vim.o.columns - 25 then
      return true
    end
  end

  return false
end

local function reverse_table(t)
  local tmp = {}

  for i = 1, #t do
    local key = #t + 1 - i
    tmp[i] = t[key]
  end
  return tmp
end

local get_icon

local function build_item(bufnr, n)
  local name = vim.fn.bufname(bufnr)

  local tablineat = '%' .. n .. '@v:lua.__nvim_tabline.jump@'

  if name == '' then
    name = 'No Name'
  else
    name = vim.fn.fnamemodify(name, ':t')
  end
  local item_hilight

  if vim.api.nvim_buf_get_option(bufnr, 'modified') then
    if bufnr == vim.api.nvim_get_current_buf() then
      item_hilight = 'TablineNvimM'
    else
      item_hilight = 'TablineNvimMNC'
    end
  elseif bufnr == vim.api.nvim_get_current_buf() then
    item_hilight = 'TablineNvimA'
  else
    item_hilight = 'TablineNvimB'
  end

  if show_index then
    n = util.get_index_icon(n, index_type)
    if get_icon then
      local icon, hl = get_icon(name)
      if not icon or not hl then
        name = n .. ' ' .. name
      else
        if not devicon_hls[item_hilight .. hl] then
          local info = vim.api.nvim_get_hl(0, { name = item_hilight })
          local icon_hl = vim.api.nvim_get_hl(0, { name = hl })
          vim.api.nvim_set_hl(0, item_hilight .. hl, {
            fg = icon_hl.fg,
            bg = info.bg,
          })
        end
        local index_sep
        if index_type <= 2 then
            index_sep = '  '
        else
            index_sep = ' '
        end
        name = n
          .. '%#'
          .. item_hilight
          .. hl
          .. '#' .. index_sep
          .. icon
          .. ' %#'
          .. item_hilight
          .. '#'
          .. name
      end
    else
      name = n .. ' ' .. name
    end
  end

  return {
    str = '%#' .. item_hilight .. '# ' .. tablineat .. ' ' .. name .. ' ',
    bufnr = bufnr,
    len = #name + 4,
    pin = false,
  }
end

local function build_tab_item(tabid)
  local bufnr = vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(tabid))

  local name = vim.fn.bufname(bufnr)

  local nr = vim.api.nvim_tabpage_get_number(tabid)

  local tablineat = '%' .. nr .. '@v:lua.__nvim_tabline.jump@'

  if name == '' then
    name = 'No Name'
  else
    name = vim.fn.fnamemodify(name, ':t')
  end

  local item_hilight

  if vim.api.nvim_buf_get_option(bufnr, 'modified') then
    item_hilight = '%#TablineNvimM# '
  elseif bufnr == vim.api.nvim_get_current_buf() then
    item_hilight = '%#TablineNvimA# '
  else
    item_hilight = '%#TablineNvimB# '
  end

  return {
    str = item_hilight .. tablineat .. ' ' .. name .. ' ',
    bufnr = bufnr,
    len = #name + 4,
    pin = false,
  }
end

local function tabline_sep(a, b)
  local hi_a
  local hi_b

  if not a then
    hi_a = 'TablineNvimB'
  elseif vim.api.nvim_buf_get_option(a.bufnr, 'modified') then
    if a.bufnr == vim.api.nvim_get_current_buf() then
      hi_a = 'TablineNvimM'
    else
      hi_a = 'TablineNvimMNC'
    end
  elseif a.bufnr == vim.api.nvim_get_current_buf() then
    hi_a = 'TablineNvimA'
  else
    hi_a = 'TablineNvimB'
  end
  if not b then
    hi_b = 'TablineNvimB'
  elseif vim.api.nvim_buf_get_option(b.bufnr, 'modified') then
    if b.bufnr == vim.api.nvim_get_current_buf() then
      hi_b = 'TablineNvimM'
    else
      hi_b = 'TablineNvimMNC'
    end
  elseif b.bufnr == vim.api.nvim_get_current_buf() then
    hi_b = 'TablineNvimA'
  else
    hi_b = 'TablineNvimB'
  end

  if hi_a == hi_b then
    return isep
  end

  return '%#' .. hi_a .. '_' .. hi_b .. '#' .. right_sep
end

local function index(list, item)
  local n = 0
  for _, v in ipairs(list) do
    if v == item then
      return n
    end
    n = n + 1
  end
  return -1
end

local function get_show_items()
  if vim.fn.tabpagenr('$') > 1 then
    shown_items = {}
    for _, i in ipairs(vim.api.nvim_list_tabpages()) do
      table.insert(shown_items, build_tab_item(i))
    end
    return shown_items
  else
    shown_items = {}

    left_hide_bufs = vim.tbl_filter(function(val)
      return vim.api.nvim_buf_is_valid(val) and vim.api.nvim_buf_get_option(val, 'buflisted')
    end, left_hide_bufs)
    right_hide_bufs = vim.tbl_filter(function(val)
      return vim.api.nvim_buf_is_valid(val) and vim.api.nvim_buf_get_option(val, 'buflisted')
    end, right_hide_bufs)
    local origin_ct = #visiable_bufs
    visiable_bufs = vim.tbl_filter(function(val)
      return vim.api.nvim_buf_is_valid(val) and vim.api.nvim_buf_get_option(val, 'buflisted')
    end, visiable_bufs)
    if #visiable_bufs ~= origin_ct then
      local matchlen = false

      if #right_hide_bufs > 0 and not matchlen then
        while not matchlen and #right_hide_bufs > 0 do
          table.insert(visiable_bufs, table.remove(right_hide_bufs))
          if check_len(visiable_bufs) then
            matchlen = true
            table.insert(right_hide_bufs, 1, table.remove(visiable_bufs, #visiable_bufs))
          end
        end
      end
      if #left_hide_bufs > 0 and not matchlen then
        while not matchlen and #left_hide_bufs > 0 do
          table.insert(visiable_bufs, 1, table.remove(left_hide_bufs, #left_hide_bufs))
          if check_len(visiable_bufs) then
            matchlen = true
            table.insert(left_hide_bufs, table.remove(visiable_bufs, 1))
          end
        end
      end
    end
    local n = 1
    for _, bufnr in ipairs(visiable_bufs) do
      table.insert(shown_items, build_item(bufnr, n))
      n = n + 1
    end
    return shown_items
  end
end

function M.add(bufnr) end

function M.move_to_previous()
  local ntp = vim.fn.tabpagenr('$')
  if ntp > 1 then
    local ctpn = vim.fn.tabpagenr()
    local idx = ctpn - 2
    if idx == -1 then
      idx = ntp
    end
    vim.cmd('tabmove ' .. idx)
  else
    local bufnr = vim.api.nvim_get_current_buf()

    local idx = index(visiable_bufs, bufnr)

    if idx > 0 then -- second item or others
      visiable_bufs[idx + 1] = visiable_bufs[idx]
      visiable_bufs[idx] = bufnr
    elseif idx == 0 and #left_hide_bufs > 0 then
      table.insert(visiable_bufs, 2, table.remove(left_hide_bufs, #left_hide_bufs))
      while check_len(visiable_bufs) and #visiable_bufs > 1 do
        table.insert(right_hide_bufs, 1, table.remove(visiable_bufs, #visiable_bufs))
      end
    end
  end

  vim.cmd('redrawtabline')
end

function M.move_to_next()
  local ntp = vim.fn.tabpagenr('$')
  if ntp > 1 then
    local ctpn = vim.fn.tabpagenr()
    local idx = ctpn + 1
    if idx > ntp then
      idx = 0
    end
    vim.cmd('tabmove ' .. idx)
  else
    local bufnr = vim.api.nvim_get_current_buf()

    local idx = index(visiable_bufs, bufnr)

    if idx > -1 and idx < #visiable_bufs - 1 then -- second item or others
      visiable_bufs[idx + 1] = visiable_bufs[idx + 2]
      visiable_bufs[idx + 2] = bufnr
    elseif idx == #visiable_bufs - 1 and #right_hide_bufs > 0 then
      table.insert(visiable_bufs, #visiable_bufs - 1, table.remove(right_hide_bufs, 1))
      while check_len(visiable_bufs) and #visiable_bufs > 1 do
        table.insert(left_hide_bufs, table.remove(visiable_bufs, 1))
      end
    end
  end

  vim.cmd('redrawtabline')
end

function M.close_current_buffer()
  if index({ 'defx', 'startify' }, vim.o.filetype) ~= -1 then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()

  local idx = index(visiable_bufs, bufnr)

  local f = ''
  if vim.api.nvim_buf_get_option(bufnr, 'modified') then
    vim.api.nvim_echo(
      { { 'save changes to "' .. vim.fn.bufname(bufnr) .. '"?  Yes/No/Cancel', 'WarningMsg' } },
      false,
      {}
    )
    local rs = vim.fn.getchar()
    vim.cmd.redraw()
    if rs == 'y' then
      vim.cmd.write()
    elseif rs == 'n' then
      f = '!'
      vim.api.nvim_echo({ { 'discarded', 'None' } }, false, {})
    else
      vim.api.nvim_echo({ { 'canceled!', 'None' } }, false, {})
      return
    end
  end

  if idx > 0 then
    vim.cmd('b' .. visiable_bufs[idx])
    vim.cmd('bd' .. f .. ' ' .. bufnr)
  elseif idx == 0 and #visiable_bufs > 1 then
    vim.cmd('b' .. visiable_bufs[1])
    vim.cmd('bd' .. f .. ' ' .. bufnr)
  elseif idx == 0 and #visiable_bufs == 1 then
    vim.cmd('Startify')
    vim.cmd('bd' .. f .. ' ' .. bufnr)
  end
end

function M.setup(opts)
  opts = opts or {}
  local seps = separators[opts.separator or 'arrow']
  local iseps = i_separators[opts.iseparator or 'arrow']
  show_index = opts.show_index or show_index
  index_type = opts.index_type or index_type
  isep = iseps[1]
  right_sep = seps[1]
  left_sep = seps[2]
  for bufnr = 1, vim.fn.bufnr('$') do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_option(bufnr, 'buflisted') then
      table.insert(visiable_bufs, bufnr)
    end
  end
  local tabline_augroup = vim.api.nvim_create_augroup('tabline.nvim', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufAdd' }, {
    callback = vim.schedule_wrap(function(event)
      if
        vim.api.nvim_buf_is_valid(event.buf)
        and index(right_hide_bufs, event.buf) == -1
        and index(visiable_bufs, event.buf) == -1
        and index(left_hide_bufs, event.buf) == -1
      then
        if event.buf == vim.api.nvim_get_current_buf() then
          table.insert(visiable_bufs, event.buf)
        else
          table.insert(right_hide_bufs, event.buf)
        end
        vim.cmd('redrawtabline')
      end
    end),
    group = tabline_augroup,
  })
  vim.api.nvim_create_autocmd({
    'BufEnter',
  }, {
    callback = vim.schedule_wrap(function(event)
      if
        vim.api.nvim_buf_is_valid(event.buf) and vim.api.nvim_buf_get_option(event.buf, 'buflisted')
      then
        if index(visiable_bufs, event.buf) == -1 then
          if index(left_hide_bufs, event.buf) > -1 then
            local all_bufs = {}
            for _, v in ipairs(left_hide_bufs) do
              table.insert(all_bufs, v)
            end
            for _, v in ipairs(visiable_bufs) do
              table.insert(all_bufs, v)
            end
            for _, v in ipairs(right_hide_bufs) do
              table.insert(all_bufs, v)
            end
            left_hide_bufs = {}
            visiable_bufs = {}
            right_hide_bufs = {}

            local find_current_buf = false
            local matchlen = false

            for _, v in ipairs(all_bufs) do
              if v == event.buf then
                find_current_buf = true
              end

              if not find_current_buf then
                table.insert(left_hide_bufs, v)
              elseif find_current_buf and not matchlen then
                table.insert(visiable_bufs, v)
                if check_len(visiable_bufs) then
                  matchlen = true
                  if #visiable_bufs > 1 then
                    table.insert(right_hide_bufs, table.remove(visiable_bufs, #visiable_bufs))
                  end
                end
              else
                table.insert(right_hide_bufs, v)
              end
            end
          elseif index(right_hide_bufs, event.buf) > -1 then
            local all_bufs = {}
            for _, v in ipairs(left_hide_bufs) do
              table.insert(all_bufs, v)
            end
            for _, v in ipairs(visiable_bufs) do
              table.insert(all_bufs, v)
            end
            for _, v in ipairs(right_hide_bufs) do
              table.insert(all_bufs, v)
            end
            left_hide_bufs = {}
            visiable_bufs = {}
            right_hide_bufs = {}

            local find_current_buf = false
            local matchlen = false

            all_bufs = reverse_table(all_bufs)

            for _, v in ipairs(all_bufs) do
              if v == event.buf then
                find_current_buf = true
              end

              if not find_current_buf then
                table.insert(right_hide_bufs, 1, v)
              elseif find_current_buf and not matchlen then
                table.insert(visiable_bufs, 1, v)
                if check_len(visiable_bufs) then
                  matchlen = true
                  if #visiable_bufs > 1 then
                    table.insert(left_hide_bufs, table.remove(visiable_bufs, 1))
                  end
                end
              else
                table.insert(left_hide_bufs, 1, v)
              end
            end
          end
        end
      end
    end),
    group = tabline_augroup,
  })
  vim.api.nvim_create_autocmd({
    'BufWinEnter',
    'BufWinLeave',
    'BufWritePost',
    'TabEnter',
    'VimResized',
    'WinEnter',
    'WinLeave',
  }, {
    callback = vim.schedule_wrap(function(event)
      if vim.api.nvim_buf_is_valid(event.buf) then
        vim.cmd('redrawtabline')
      end
    end),
    group = tabline_augroup,
  })
  M.def_colors()
  vim.o.showtabline = 2
  vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
    group = tabline_augroup,
    pattern = { '*' },
    callback = function(_)
      M.def_colors()
    end,
  })
  vim.cmd("set tabline=%!v:lua.require('tabline').get()")
end

function M.get()
  if not get_icon then
    local ok, devicon = pcall(require, 'nvim-web-devicons')
    if ok then
      get_icon = devicon.get_icon
    end
  end
  local tablinestr = ''
  shown_items = get_show_items()
  local preview_item
  if #left_hide_bufs > 0 and vim.fn.tabpagenr('$') == 1 then
    tablinestr = '%#TablineNvimB# << '
      .. #left_hide_bufs
      .. ' '
      .. tabline_sep(preview_item, shown_items[1])
  end
  for _, item in ipairs(shown_items) do
    if preview_item then
      -- 如果存在上一个buf，则增加分隔符
      tablinestr = tablinestr .. tabline_sep(preview_item, item)
    end
    tablinestr = tablinestr .. item.str
    preview_item = item
  end

  if preview_item then
    -- 如果存在上一个buf，则增加分隔符
    tablinestr = tablinestr .. tabline_sep(preview_item, nil)

    if #right_hide_bufs > 0 and vim.fn.tabpagenr('$') == 1 then
      tablinestr = tablinestr .. '%#TablineNvimB# ' .. #right_hide_bufs .. ' >> '
    end
    tablinestr = tablinestr .. '%#TablineNvimB#%=%#TablineNvimA_TablineNvimB# ' .. left_sep
    if vim.fn.tabpagenr('$') > 1 then
      tablinestr = tablinestr .. '%#TablineNvimA# Tabs '
    else
      tablinestr = tablinestr .. '%#TablineNvimA# Buffers '
    end
  end
  return tablinestr
end

function M.def_colors()
  local ok, t = pcall(require, 'tabline.themes.' .. vim.g.colors_name)
  if not ok then
    t = require('tabline.themes.one')
  end

  vim.api.nvim_set_hl(0, 'TablineNvimA', {
    fg = t[1][1],
    bg = t[1][2],
    ctermfg = t[1][4],
    ctermbg = t[1][3],
  })
  vim.api.nvim_set_hl(0, 'TablineNvimB', {
    fg = t[2][1],
    bg = t[2][2],
    ctermfg = t[2][4],
    ctermbg = t[2][3],
  })
  vim.api.nvim_set_hl(0, 'TablineNvimM', {
    fg = t[5][1],
    bg = t[5][2],
    ctermfg = t[5][3],
    ctermbg = t[5][4],
  })
  vim.api.nvim_set_hl(0, 'TablineNvimMNC', {
    fg = t[5][2],
    bg = t[2][2],
    ctermfg = t[5][4],
    ctermbg = t[2][3],
  })
  util.hi_separator('TablineNvimA', 'TablineNvimB')
  util.hi_separator('TablineNvimA', 'TablineNvimM')
  util.hi_separator('TablineNvimA', 'TablineNvimMNC')
  util.hi_separator('TablineNvimB', 'TablineNvimA')
  util.hi_separator('TablineNvimB', 'TablineNvimM')
  util.hi_separator('TablineNvimB', 'TablineNvimMNC')
  util.hi_separator('TablineNvimM', 'TablineNvimA')
  util.hi_separator('TablineNvimM', 'TablineNvimB')
  util.hi_separator('TablineNvimM', 'TablineNvimMC')
  util.hi_separator('TablineNvimMNC', 'TablineNvimA')
  util.hi_separator('TablineNvimMNC', 'TablineNvimB')
  util.hi_separator('TablineNvimMNC', 'TablineNvimM')
end

local function is_best_win(winid)
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local ft = vim.bo[bufnr].filetype
  if ft == 'defx' or ft == 'nerdtree' or ft == 'tagbar' then
    return false
  end

  return true
end

local function open_in_best_win(bufnr)
  if is_best_win(vim.api.nvim_get_current_win()) then
    vim.api.nvim_set_current_buf(bufnr)
    return
  end
  for winnr = 1, vim.fn.winnr('$') do
    local winid = vim.fn.win_getid(winnr)
    if is_best_win(winid) and not util.is_float(winid) then
      vim.api.nvim_set_current_win(winid)
      vim.api.nvim_set_current_buf(bufnr)
    end
  end
end

function M.jump(id)
  if id == 'next' then
    if vim.fn.tabpagenr('$') > 1 then
      vim.cmd('tabnext')
    else
      local bufnr = vim.api.nvim_get_current_buf()

      local idx = index(visiable_bufs, bufnr)

      if idx > -1 and idx < #visiable_bufs - 1 then
        vim.cmd('b' .. visiable_bufs[idx + 2])
      elseif idx > -1 and idx == #visiable_bufs - 1 then
        if #right_hide_bufs > 0 then
          vim.cmd('b' .. right_hide_bufs[1])
        elseif #left_hide_bufs > 0 then
          vim.cmd('b' .. left_hide_bufs[1])
        else
          vim.cmd('b' .. visiable_bufs[1])
        end
      end
    end
  elseif id == 'prev' then
    if vim.fn.tabpagenr('$') > 1 then
      vim.cmd('tabprevious')
    else
      local bufnr = vim.api.nvim_get_current_buf()

      local idx = index(visiable_bufs, bufnr)

      if idx > 0 then
        vim.cmd('b' .. visiable_bufs[idx])
      elseif idx == 0 and idx < #visiable_bufs - 1 then
        if #left_hide_bufs > 0 then
          vim.cmd('b' .. left_hide_bufs[#left_hide_bufs])
        elseif #right_hide_bufs > 0 then
          vim.cmd('b' .. right_hide_bufs[#right_hide_bufs])
        else
          vim.cmd('b' .. visiable_bufs[#visiable_bufs])
        end
      end
    end
  elseif #shown_items >= id then
    if vim.fn.tabpagenr('$') > 1 then
      vim.cmd('tabnext' .. id)
    else
      open_in_best_win(shown_items[id].bufnr)
    end
  end
end

_G.__nvim_tabline = { jump = M.jump }

return M
