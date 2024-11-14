local M = {}

local function debug_log(message)
  vim.notify("[GitHub Navigator Debug]: " .. message, vim.log.levels.INFO)
end

local function get_git_repo_root()
  local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  if not handle then return nil end
  local result = handle:read("*a"):gsub("%s+$", "")
  handle:close()
  return result ~= "" and result or nil
end

local function get_relative_file_path()
  local repo_root = get_git_repo_root()
  if not repo_root then
    vim.notify("Not inside a Git repository", vim.log.levels.ERROR)
    return nil
  end
  local file_path = vim.fn.expand("%:p")
  return file_path:sub(#repo_root + 2)
end

local function get_current_line_number()
  return vim.fn.line(".")
end

local function get_github_url()
  local handle = io.popen("git remote get-url origin 2>/dev/null")
  if not handle then return nil end
  local origin_url = handle:read("*a"):gsub("%s+$", "")
  handle:close()

  if origin_url:match("^git@") then
    -- Convert SSH URL to HTTPS
    origin_url = origin_url:gsub(":", "/"):gsub("git@", "https://")
  elseif not origin_url:match("^https://") then
    vim.notify("Unsupported Git remote URL format", vim.log.levels.ERROR)
    return nil
  end

  -- Remove the .git suffix if present
  origin_url = origin_url:gsub("%.git$", "")

  local file_path = get_relative_file_path()
  if not file_path then return nil end

  local line_number = get_current_line_number()
  return string.format("%s/blob/main/%s#L%d", origin_url, file_path, line_number)
end


function M.open_in_github()
  local url = get_github_url()
  if not url then
    vim.notify("Could not generate GitHub URL", vim.log.levels.ERROR)
    return
  end

  -- Copy the URL to the system clipboard
  vim.fn.setreg("+", url)
  vim.notify("Copied to clipboard: " .. url, vim.log.levels.INFO)

  -- Open the URL in the default web browser
  local open_cmd
  if vim.fn.has("unix") == 1 then
    open_cmd = "xdg-open"  -- Linux
  elseif vim.fn.has("mac") == 1 then
    open_cmd = "open"      -- macOS
  elseif vim.fn.has("win32") == 1 then
    open_cmd = "start"     -- Windows
  else
    vim.notify("Unsupported OS for automatic browser launch", vim.log.levels.WARN)
    return
  end

  vim.fn.jobstart({open_cmd, url}, {detach = true})
end

return M

