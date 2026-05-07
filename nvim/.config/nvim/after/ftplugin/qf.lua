local function delete_qf_entries(start, count)
  local qflist = vim.fn.getqflist()
  for _ = 1, count do
    table.remove(qflist, start)
  end
  vim.fn.setqflist(qflist, 'r')
  local new_line = math.min(start, #qflist)
  if new_line > 0 then
    vim.api.nvim_win_set_cursor(0, { new_line, 0 })
  end
end

vim.keymap.set('n', 'dd', function()
  delete_qf_entries(vim.fn.line('.'), vim.v.count1)
end, { buffer = true })

vim.keymap.set('n', 'dj', function()
  local lnum = vim.fn.line('.')
  delete_qf_entries(lnum, vim.v.count1 + 1)
end, { buffer = true })

vim.keymap.set('n', 'dk', function()
  local lnum = vim.fn.line('.')
  local count = vim.v.count1
  local start = math.max(1, lnum - count)
  delete_qf_entries(start, lnum - start + 1)
end, { buffer = true })
