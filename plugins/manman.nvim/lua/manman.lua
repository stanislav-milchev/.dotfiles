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

-- Set up key mappings
function M.setup()
    vim.api.nvim_set_keymap("n", "m1", "<cmd>lua require('manman').open_man(1)<CR>",
        { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "m2", "<cmd>lua require('manman').open_man(2)<CR>",
        { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "m3", "<cmd>lua require('manman').open_man(3)<CR>",
        { noremap = true, silent = true })
end

return M

