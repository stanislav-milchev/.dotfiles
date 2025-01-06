local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

-- Pin to a specific commit after cloning
vim.fn.system({
  "git",
  "-C",
  lazypath,
  "checkout",
  "31ddbea7c10b6920c9077b66c97951ca8682d5c8",  -- Replace with the desired commit hash
})

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    "ThePrimeagen/vim-be-good",
    spec = "theprimeagen.lazy",
    change_detection = { notify = false }
})
