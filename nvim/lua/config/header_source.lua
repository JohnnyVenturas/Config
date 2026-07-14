-- Toggle between a source file and its corresponding header (and back).
-- Press `gh` in normal mode to jump to the counterpart of the current file.

-- Extension groups. Case-insensitive: the matching is done in lowercase, so
-- .c/.C, .cpp/.CPP, .h/.H, etc. are all handled.
local source_exts = { 'c', 'cc', 'cpp', 'cxx', 'c++', 'cp' }
local header_exts = { 'h', 'hh', 'hpp', 'hxx', 'h++', 'hp', 'inl', 'tpp', 'ipp' }

local function to_set(list)
  local set = {}
  for _, e in ipairs(list) do
    set[e] = true
  end
  return set
end

local source_set = to_set(source_exts)
local header_set = to_set(header_exts)

local function switch_header_source()
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then
    vim.notify('No file in current buffer', vim.log.levels.WARN)
    return
  end

  local dir = vim.fn.fnamemodify(path, ':h')
  local stem = vim.fn.fnamemodify(path, ':t:r') -- filename without extension
  local ext = vim.fn.fnamemodify(path, ':e'):lower()

  -- Pick the opposite group of extensions to look for.
  local targets
  if source_set[ext] then
    targets = header_exts
  elseif header_set[ext] then
    targets = source_exts
  else
    vim.notify('Not a C/C++ source or header file: .' .. ext, vim.log.levels.WARN)
    return
  end

  -- Look for the first counterpart that exists on disk, trying both the
  -- lowercase and uppercase spelling of each candidate extension.
  for _, t in ipairs(targets) do
    for _, cand_ext in ipairs({ t, t:upper() }) do
      local candidate = dir .. '/' .. stem .. '.' .. cand_ext
      if vim.fn.filereadable(candidate) == 1 then
        vim.cmd.edit(vim.fn.fnameescape(candidate))
        return
      end
    end
  end

  vim.notify('No counterpart file found for ' .. vim.fn.fnamemodify(path, ':t'), vim.log.levels.INFO)
end

vim.keymap.set('n', 'gh', switch_header_source, {
  noremap = true,
  silent = true,
  desc = 'Switch between source and header file',
})
