local M = {}

function M.makeTable(bang, line1, line2, ...)
  local sep = select(1, ...) or ','
  local ncols = 0
  local rows = {}

  -- Get and split lines
  for i = line1, line2 do
    local line = vim.fn.getline(i)
    table.insert(rows, vim.fn.split(line, sep))
  end

  -- Exit if rows are empty
  if #rows <= 1 and #rows[1] == 1 and rows[1][1] == '' then
    return
  end

  -- Calculate number of columns
  for _, row in ipairs(rows) do
    local ncol = #row
    if ncol > ncols then
      ncols = ncol
    end
  end

  -- Align the length of each row
  for i = 1, #rows do
    rows[i] = vim.tbl_map(function(val)
      return vim.fn.substitute(val, '^%s+|%s+$', '', 'g')
    end, rows[i])
    for _ = #rows[i] + 1, ncols do
      table.insert(rows[i], '')
    end
  end

  -- Calculate the maximum width of each column
  local widths = {}
  for c = 1, ncols do
    local max_width = 0
    for r = 1, #rows do
      local width = vim.fn.strdisplaywidth(rows[r][c])
      if width > max_width then
        max_width = width
      end
    end
    widths[c] = max_width
  end

  -- Align each cell to the maximum width
  for r = 1, #rows do
    for c = 1, ncols do
      rows[r][c] = rows[r][c] .. string.rep(' ', widths[c] - vim.fn.strdisplaywidth(rows[r][c]))
    end
  end

  -- Create separator row
  local separator = {}
  for c = 1, ncols do
    table.insert(separator, string.rep('-', widths[c]))
  end

  -- Convert to table format
  for r = 1, #rows do
    rows[r] = '|' .. table.concat(rows[r], '|') .. '|'
  end

  -- Replace lines
  local pos = vim.fn.getpos('.')
  vim.cmd(string.format('%d,%dd', line1, line2))

  if bang then
    table.insert(rows, 2, '|' .. table.concat(separator, '|') .. '|')
  else
    table.insert(rows, 1, '|' .. table.concat(separator, '|') .. '|')
  --  table.insert(rows, 1, '|' .. table.concat(vim.tbl_map(function() return ' ' end, separator), '|') .. '|')
    local spaces = vim.tbl_map(function(item) return string.rep(' ', #item) end, separator)
    table.insert(rows, 1, '|' .. table.concat(spaces, '|') .. '|')
  end

  vim.fn.append(line1 - 1, rows)
  vim.fn.setpos('.', pos)
end

function M.unmakeTable(...)
  local sep = select(1, ...) or ','
  local start = vim.fn.search('^$', 'bcnW')
  local finish = vim.fn.search('^$', 'ncW')

  if start == 0 then
    start = 1
  else
    start = start + 1
  end

  if finish == 0 then
    finish = vim.fn.line('$')
  else
    finish = finish - 1
  end

  local lines = vim.fn.getline(start, finish)
  lines = vim.tbl_filter(function(line)
    return not line:match('^|[-:|]+|$')
  end, lines)

  lines = vim.tbl_map(function(line)
    return line:gsub('^%s*|%s*', ''):gsub('%s*|%s*', sep):gsub('%s*|%s*$', '')
  end, lines)

  vim.cmd(string.format('%d,%d d', start, finish))
  vim.fn.append(start - 1, lines)
end


function M.setup()
  vim.api.nvim_create_user_command('MakeTable', function(opts)
    M.makeTable(opts.bang, opts.line1, opts.line2, unpack(opts.fargs))
  end, {bang = true, range = true, nargs = '?'})

  vim.api.nvim_create_user_command('UnmakeTable', function(opts)
    M.unmakeTable(unpack(opts.fargs))
  end, {bang = true, nargs = '?'})
end

return M
