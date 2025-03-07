local local_plugins = {
    {
        dir = "~/personal/plugins/ghnav.nvim",
        config = function()
            require("ghnav")
        end
    },
    {
        dir = "~/personal/plugins/manman.nvim",
        config = function()
            require("manman").setup()
        end
    },
    {
        dir = "~/personal/plugins/coomit.nvim",
        config = function()
            require("coomit").setup()
        end
    }
}

return local_plugins
