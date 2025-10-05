vim.api.nvim_create_augroup("DapGroup", { clear = true })

local function navigate(args)
    local buffer = args.buf
    local wid = nil
    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win_id) == buffer then
            wid = win_id
        end
    end
    if wid then
        vim.schedule(function()
            if vim.api.nvim_win_is_valid(wid) then
                vim.api.nvim_set_current_win(wid)
            end
        end)
    end
end

local function create_nav_options(name)
    return {
        group = "DapGroup",
        pattern = string.format("*%s*", name),
        callback = navigate
    }
end

return {
    {
        "mfussenegger/nvim-dap",
        lazy = false,
        config = function()
            local dap = require("dap")

            -- 🔧 Adapter setup for Delve
            dap.adapters.go = {
                type = "server",
                port = "${port}",
                executable = {
                    command = vim.fn.stdpath("data") .. "/mason/bin/dlv",
                    args = { "dap", "-l", "127.0.0.1:${port}" },
                },
            }

            -- 🚀 Launch configurations
            dap.configurations.go = {
                {
                    type = "go",
                    name = "Debug productapi",
                    request = "launch",
                    program = "${workspaceFolder}/cmd/productapi",
                    args = function()
                        return vim.split(vim.fn.input("Args: "), " ")
                    end,
                },
                {
                    type = "go",
                    name = "Debug controller",
                    request = "launch",
                    program = "${workspaceFolder}/cmd/controller",
                },
                {
                    type = "go",
                    name = "Debug differ",
                    request = "launch",
                    program = "${workspaceFolder}/cmd/differ",
                },
            }

            -- 🧠 Keymaps
            vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
            vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
            vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
            vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
            vim.keymap.set("n", "<F4>", dap.run_last)

            -- 🎯 Highlights + signs
            vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, bg = "#928374" })
            vim.fn.sign_define("DapStopped",
                { text = "▶", texthl = "DiagnosticSignWarn", linehl = "DapStoppedLine", numhl = "DapStoppedLine" })
            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticSignError" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "●", texthl = "DiagnosticSignWarn" })

            -- 🔦 Visual line for current stop
            dap.listeners.after.event_stopped["highlight_stopped"] = function(_, body)
                local frame = body and body.frame
                if not frame or not frame.source or not frame.line then
                    return
                end

                local buf = vim.fn.bufnr(frame.source.path)
                local line = frame.line

                -- Apply highlight to the stopped line
                vim.api.nvim_buf_add_highlight(buf, -1, "DapStoppedLine", line - 1, 0, -1)

                -- Place a sign in the gutter
                vim.fn.sign_place(0, "DapStoppedGroup", "DapStopped", buf, { lnum = line, priority = 200 })
            end

            dap.listeners.before.event_continued["clear_stopped"] = function()
                vim.api.nvim_buf_clear_namespace(0, -1, 0, -1)
                vim.fn.sign_unplace("DapStoppedGroup")
            end
            dap.listeners.before.event_terminated["clear_stopped"] = dap.listeners.before.event_continued
                ["clear_stopped"]
        end,
    },

    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            dapui.setup({
                layouts = {
                    {
                        elements = {
                            { id = "scopes", size = 0.5 },
                            { id = "repl",   size = 0.5 },
                        },
                        position = "right",
                        size = 50,
                    },
                    {
                        elements = {
                            { id = "breakpoints" },
                            { id = "stacks" },
                            { id = "watches" },
                        },
                        position = "bottom",
                        size = 10,
                    },
                },
                controls = {
                    enabled = true,
                    element = "repl",
                    icons = {
                        pause = "⏸",
                        play = "▶",
                        step_into = "⏎",
                        step_over = "⏭",
                        step_out = "⇤",
                        step_back = "↩",
                        run_last = "↻",
                        terminate = "⏹"
                    }
                }
            })

            dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
            dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
            dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

            -- 🔁 Navigation & autocmd
            vim.api.nvim_create_autocmd("BufWinEnter", create_nav_options("dap-repl"))
            vim.api.nvim_create_autocmd("BufWinEnter", create_nav_options("DAP Watches"))

            -- UI toggles
            vim.keymap.set("n", "<leader>dd", dapui.toggle, { desc = "Toggle DAP UI" })
        end,
    },

    {
        "Weissle/persistent-breakpoints.nvim",
        config = function()
            local pb = require("persistent-breakpoints")
            pb.setup({
                save_dir = vim.fn.stdpath('data') .. '/nvim_checkpoints',
                load_breakpoints_event = "BufReadPost",
                perf_record = false,
            })

            -- 🔘 Keymaps
            vim.keymap.set("n", "<leader>b", function()
                require("persistent-breakpoints.api").toggle_breakpoint()
            end, { desc = "Toggle Breakpoint" })

            vim.keymap.set("n", "<leader>B", function()
                require("persistent-breakpoints.api").set_conditional_breakpoint()
            end, { desc = "Conditional Breakpoint" })
        end,
    },

    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
        },
        config = function()
            require("mason-nvim-dap").setup({
                ensure_installed = { "delve" },
                automatic_installation = true,
            })
        end,
    },
}

