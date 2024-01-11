-----------------------------
-- EzBookmarks by lifer0se --
-----------------------------

local bookmark_file = vim.fn.stdpath('data') .. '/ezbookmarks.txt'
local u = assert(io.popen("echo $HOME", 'r'))
local home_path = assert(u:read('*a')):gsub("\n","")
u:close()

local M = {}

M.get_lines_from_bookmark_file = function ()
  local lines = {}
  if vim.fn.filereadable(bookmark_file) == 0 then
    return lines
  end

  local has_changes = false
  for line in io.lines(bookmark_file) do
    if vim.fn.filereadable(line) == 1 or vim.fn.isdirectory(line) == 1 then
      lines[#lines + 1] = line
    else
      has_changes = true
    end
  end

  if has_changes then
    local n = ""
    for k, v in pairs(lines) do
      n = n .. v .. '\n'
    end
    local f = io.open(bookmark_file, 'w')
    f:write(n)
    f:close()
  end

  return lines
end


M.bookmark_exists = function (path)
  local lines = M.get_lines_from_bookmark_file()
  for k, v in pairs(lines) do
    if (vim.fn.filereadable(v) == 1 or vim.fn.isdirectory(v) == 1) and v == path then
      return 1
    elseif vim.fn.filereadable(v) == 1 then
      for k, v in pairs(lines) do
        if string.sub(v, #v) == "/" and string.match(path, v) and v ~= path then
          return -1
        end
      end
    elseif vim.fn.isdirectory(v) == 1 and string.match(path, v) then
      return -1
    end
  end
  return 0
end

M.get_relative_path = function (path)
  -- Get current working directory
  local currentPwd = io.popen("pwd"):read("*l")

  -- Check if the given path is within the current working directory
  if string.sub(path, 1, #currentPwd) == currentPwd then
    -- Extract the relative path
    return string.sub(path, #currentPwd + 2) -- +2 to remove the leading '/'
  else
    -- Path is not within the current working directory
    return path
  end
end

M.get_absolute_path = function (path)
  -- Check if the path is already absolute
  if string.sub(path, 1, 1) == '/' then
    return path
  else
    local currentPwd = io.popen("pwd"):read("*l") -- Get current working directory

    -- Combine the current working directory with the relative path
    return currentPwd .. '/' .. path
  end
end

M.sub_home_path = function (file)
  if string.sub(file, 0, #home_path) == home_path then
    return "~" .. string.sub(file, #home_path + 1, #file)
  else
    return file
  end
end

M.get_path_from_file = function (file)
  if (vim.fn.has("win32") == 0) then
    return file:match("(.*/)")
  else
    return file:match("(.*\\)")
  end
end

return M
