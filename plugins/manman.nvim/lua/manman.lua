local M = {}

-- Function to open a man page for the given section and word
function M.open_man(section)
    local word = vim.fn.expand("<cword>")
    if word == "" then
        print("No word under the cursor.")
        return
    end

    local cmd = string.format("man %d %s", section, word)
    local output = vim.fn.system(cmd)

    if vim.v.shell_error ~= 0 then
        print(string.format("Error: No manual entry for '%s' in section %d", word, section))
        return
    end

    -- Open the man page in a floating window
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, "\n"))

    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
    })

    -- Add keymap to close the window
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>bd!<CR>", { noremap = true, silent = true })
end

-- Define the function to handle the dynamic digit
function M.manman_dynamic_open()
    local char = vim.fn.getchar()
    local digit = tonumber(vim.fn.nr2char(char))
    if digit and digit >= 1 and digit <= 9 then
        require('manman').open_man(digit)
    else
        vim.cmd("echo 'Invalid input. Press a digit between 1 and 9.'")
    end
end

-- Set up key mappings
function M.setup()
    -- Create a mapping for `m` followed by a digit
    vim.api.nvim_set_keymap("n", "<leader>m", ":lua require('manman').manman_dynamic_open()<CR>", { noremap = true, silent = true })
end

return M
