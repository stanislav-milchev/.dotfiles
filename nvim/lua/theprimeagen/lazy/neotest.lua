return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "fredrikaverpil/neotest-golang",
        "leoluz/nvim-dap-go",
        "nvim-neotest/neotest-python",   -- Python pytest support
        "nvim-neotest/neotest-vim-test", -- Adapter for running tests via vim-test
        "vim-test/vim-test",             -- Required for Mocha support
    },
    config = function()
        local neotest = require("neotest")
        neotest.setup({
            adapters = {
                require("neotest-golang")({
                    dap = { justMyCode = false },
                }),
                require("neotest-python")({
                    -- Optional configuration for pytest
                    dap = { justMyCode = false },
                }),
                require("neotest-vim-test")({
                    allow_file_types = { "javascript", "typescript" }
                })
            }
        })

        vim.g["test#strategy"] = "neovim"
        vim.g["test#neovim#term_position"] = "vert botright 80"

        vim.g["test#javascript#runner"] = "mocha"
        vim.g["test#javascript#mocha#options"] = "--recursive"

        -- Key mappings for running and debugging tests
        vim.keymap.set("n", "<leader>tr", function()
            if vim.bo.filetype == "javascript" or vim.bo.filetype == "typescript" then
                vim.cmd("TestNearest") -- Vim-test for JS/TS
            else
                neotest.run.run({
                    suite = false,
                    testify = true,
                })
            end
        end, { desc = "Debug: Running Nearest Test" })

        vim.keymap.set("n", "<leader>ts", function()
            neotest.run.run({
                suite = true,
                testify = true,
            })
        end, { desc = "Debug: Running Test Suite" })

        vim.keymap.set("n", "<leader>td", function()
            if vim.bo.filetype == "javascript" or vim.bo.filetype == "typescript" then
                vim.cmd("TestSuite") -- Vim-test for JS/TS
            else
                neotest.run.run({
                    suite = false,
                    testify = true,
                    strategy = "dap",
                })
            end
        end, { desc = "Debug: Debug Nearest Test" })

        vim.keymap.set("n", "<leader>to", function()
            neotest.output.open()
        end, { desc = "Debug: Open test output" })

        vim.keymap.set("n", "<leader>tq", function()
            if vim.bo.filetype == "javascript" or vim.bo.filetype == "typescript" then
                vim.cmd("TestFile") -- Vim-test for JS/TS
            else
                neotest.summary.toggle()
            end
        end, { desc = "Debug: Open test summary" })
    end
}
