vim.api.nvim_create_user_command('PIOMonitor', function()
    vim.cmd("!tmux split-window -hd pio device monitor")
end, {})

-- Neovim commands
vim.api.nvim_create_user_command('PIOBuild', function()
    vim.cmd('!platformio run')
end, {})

vim.api.nvim_create_user_command('PIOUpload', function()
    vim.cmd('!platformio run --target upload')
end, {})

vim.keymap.set('n', '<leader>ab', ':PIOBuild<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>au', ':PIOUpload<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>am', ':PIOMonitor<CR>', { noremap = true, silent = true })
