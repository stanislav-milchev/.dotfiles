local M = {}

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
    -- Safely compute relative path
    local rel_path = vim.fn.fnamemodify(file_path, ":." .. repo_root)
    return rel_path
end

local function get_selected_lines()
    local start_pos = vim.fn.getpos("'<")[2]
    local end_pos = vim.fn.getpos("'>")[2]

    if start_pos == 0 or end_pos == 0 or start_pos == end_pos then
        -- Not a real selection, fallback to current line
        local line = vim.fn.line(".")
        return line, line
    end

    if start_pos > end_pos then
        start_pos, end_pos = end_pos, start_pos
    end

    return start_pos, end_pos
end

local function get_default_branch()
    local handle = io.popen("git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null")
    if not handle then return "main" end
    local ref = handle:read("*a"):gsub("%s+$", "")
    handle:close()
    local branch = ref:match("refs/remotes/origin/(.+)")
    return branch or "main"
end

local function get_github_url()
    local handle = io.popen("git remote get-url origin 2>/dev/null")
    if not handle then return nil end
    local origin_url = handle:read("*a"):gsub("%s+$", "")
    handle:close()

    if origin_url:match("^git@") then
        origin_url = origin_url:gsub(":", "/"):gsub("git@", "https://")
    elseif not origin_url:match("^https://") then
        vim.notify("Unsupported Git remote URL format", vim.log.levels.ERROR)
        return nil
    end

    origin_url = origin_url:gsub("%.git$", "")
    local file_path = get_relative_file_path()
    if not file_path then return nil end

    local start_line, end_line = get_selected_lines()
    local branch = get_default_branch()

    if start_line == end_line then
        return string.format("%s/blob/%s/%s#L%d", origin_url, branch, file_path, start_line)
    else
        return string.format("%s/blob/%s/%s#L%d-L%d", origin_url, branch, file_path, start_line, end_line)
    end
end

function M.open_in_github()
    local url = get_github_url()
    if not url then
        vim.notify("Could not generate GitHub URL", vim.log.levels.ERROR)
        return
    end

    vim.fn.setreg("+", url)
    vim.notify("Copied to clipboard: " .. url, vim.log.levels.INFO)

    local open_cmd
    local uname = vim.loop.os_uname().sysname

    if uname == "Linux" then
        open_cmd = "xdg-open"
    elseif uname == "Darwin" then
        open_cmd = "open"
    elseif uname:match("Windows") or vim.fn.has("win32") == 1 then
        open_cmd = "start"
    else
        vim.notify("Unsupported OS for automatic browser launch", vim.log.levels.WARN)
        return
    end

    vim.fn.jobstart({ open_cmd, url }, { detach = true })
end

return M
