local M = {}

-- Function to create a floating window
local function create_floating_window()
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
    })

    return buf, win
end

-- Function to get the word under the cursor
local function get_commit_hash()
    return vim.fn.expand('<cword>')
end

-- Function to show git commit details in a floating window
function M.show_git_commit()
    local commit_hash = get_commit_hash()
    if not commit_hash or commit_hash == "" then
        print("No commit hash found")
        return
    end

    local cmd = "git show " .. commit_hash
    local output = vim.fn.systemlist(cmd)

    if vim.v.shell_error ~= 0 then
        print("Error running git show")
        return
    end

    local buf, win = create_floating_window()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'diff')

    -- Enable Treesitter highlighting if available
    if pcall(vim.treesitter.start, buf, 'diff') then
        vim.treesitter.start(buf, 'diff')
    end
end

-- Setup command
function M.setup()
    vim.api.nvim_create_user_command('GitShowCommit', M.show_git_commit, { nargs = 0 })
    vim.keymap.set('n', '<leader>gc', M.show_git_commit, { noremap = true, silent = true })
end

return M

