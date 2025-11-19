local M = {}

M.group2dict = function(name)
  local id = vim.fn.hlID(name)
  if id == 0 then
    return {
      name = '',
      ctermbg = '',
      ctermfg = '',
      bold = '',
      italic = '',
      reverse = '',
      underline = '',
      guibg = '',
      guifg = '',
    }
  end
  local rst = {
    name = vim.fn.synIDattr(id, 'name'),
    ctermbg = vim.fn.synIDattr(id, 'bg', 'cterm'),
    ctermfg = vim.fn.synIDattr(id, 'fg', 'cterm'),
    bold = vim.fn.synIDattr(id, 'bold'),
    italic = vim.fn.synIDattr(id, 'italic'),
    reverse = vim.fn.synIDattr(id, 'reverse'),
    underline = vim.fn.synIDattr(id, 'underline'),
    guibg = vim.fn.tolower(vim.fn.synIDattr(id, 'bg#', 'gui')),
    guifg = vim.fn.tolower(vim.fn.synIDattr(id, 'fg#', 'gui')),
  }
  return rst
end

M.hide_in_normal = function(name)
  local group = M.group2dict(name)
  if vim.fn.empty(group) == 1 then
    return
  end
  local normal = M.group2dict('Normal')
  local guibg = normal.guibg or ''
  local ctermbg = normal.ctermbg or ''
  group.guifg = guibg
  group.guibg = guibg
  group.ctermfg = ctermbg
  group.ctermbg = ctermbg
  group.blend = 100
  M.hi(group)
end

M.hi = function(info)
  if vim.fn.empty(info) == 1 or vim.fn.get(info, 'name', '') == '' then
    return
  end
  vim.cmd('silent! hi clear ' .. info.name)
  local cmd = 'silent hi! ' .. info.name
  if vim.fn.empty(info.ctermbg) == 0 then
    cmd = cmd .. ' ctermbg=' .. info.ctermbg
  end
  if vim.fn.empty(info.ctermfg) == 0 then
    cmd = cmd .. ' ctermfg=' .. info.ctermfg
  end
  if vim.fn.empty(info.guibg) == 0 then
    cmd = cmd .. ' guibg=' .. info.guibg
  end
  if vim.fn.empty(info.guifg) == 0 then
    cmd = cmd .. ' guifg=' .. info.guifg
  end
  local style = {}

  for _, sty in ipairs({ 'bold', 'italic', 'underline', 'reverse' }) do
    if info[sty] == 1 then
      table.insert(style, sty)
    end
  end

  if vim.fn.empty(style) == 0 then
    cmd = cmd .. ' gui=' .. vim.fn.join(style, ',') .. ' cterm=' .. vim.fn.join(style, ',')
  end
  if info.blend then
    cmd = cmd .. ' blend=' .. info.blend
  end
  pcall(vim.cmd, cmd)
end

function M.hi_separator(a, b)
  local hi_a = M.group2dict(a)
  local hi_b = M.group2dict(b)
  local hi_a_b = {
    name = a .. '_' .. b,
    guibg = hi_b.guibg,
    guifg = hi_a.guibg,
    ctermbg = hi_b.ctermbg,
    ctermfg = hi_a.ctermbg,
  }
  local hi_b_a = {
    name = b .. '_' .. a,
    guibg = hi_a.guibg,
    guifg = hi_b.guibg,
    ctermbg = hi_a.ctermbg,
    ctermfg = hi_b.ctermbg,
  }
  M.hi(hi_a_b)
  M.hi(hi_b_a)
end

-- https://github.com//wsdjeg/SpaceVim/blob/eed9d8f14951d9802665aa3429e449b71bb15a3a/autoload/SpaceVim/api/messletters.vim#L29

-- # types:
-- # 0: 1 ➛ ➊
-- # 1: 1 ➛ ➀
-- # 2: 1 ➛ ⓵
-- # 3: 1 ➛ ¹
-- # 4: 1 ➛ 1
function M.get_index_icon(n, t)
  if t == 0 then
    if n == 0 then
      return vim.fn.nr2char(9471)
    elseif n >= 1 and n <= 10 then
      return vim.fn.nr2char(10102 + n - 1)
    elseif n >= 11 and n <= 20 then
      return vim.fn.nr2char(9451 + n - 11)
    else
      return ''
    end
  elseif t == 1 then
    if n == 0 then
      return vim.fn.nr2char(9450)
    elseif n >= 1 and n <= 20 then
      return vim.fn.nr2char(9311 + n)
    else
      return ''
    end
  elseif t == 2 then
    if n >= 1 and n <= 10 then
      return vim.fn.nr2char(9461 + n - 1)
    else
      return ''
    end
  elseif t == 3 then
    local nums = { 8304, 185, 178, 179, 8308, 8309, 8310, 8311, 8312, 8313 }
    if n >= 1 and n <= 10 then
      return vim.fn.nr2char(nums[n])
    end
    return ''
  else
    return n
  end
end

return M
