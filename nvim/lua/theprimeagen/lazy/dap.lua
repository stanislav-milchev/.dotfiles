vim.api.nvim_create_augroup("DapGroup", { clear = true })

local function navigate(args)
    local buffer = args.buf

    local wid = nil
    local win_ids = vim.api.nvim_list_wins() -- Get all window IDs
    for _, win_id in ipairs(win_ids) do
        local win_bufnr = vim.api.nvim_win_get_buf(win_id)
        if win_bufnr == buffer then
            wid = win_id
        end
    end

    if wid == nil then
        return
    end

    vim.schedule(function()
        if vim.api.nvim_win_is_valid(wid) then
            vim.api.nvim_set_current_win(wid)
        end
    end)
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
            dap.set_log_level("DEBUG")

            vim.keymap.set('n', '<F4>', dap.run_last)
            vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
            vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
            vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
            vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
            -- Define highlight style for the current debugging line
            vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, bg = "#928374" }) -- Change color as needed

            -- Define a sign (icon in the gutter) for the stopped line
            vim.fn.sign_define("DapStopped",
                { text = "▶", texthl = "DiagnosticSignWarn", linehl = "DapStoppedLine", numhl = "DapStoppedLine" })
            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
            vim.fn.sign_define("DapBreakpointCondition",
                { text = "●", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" })

            -- Event listener to highlight the stopped line
            dap.listeners.after.event_stopped["highlight_stopped"] = function(session, body)
                if body and body.frame then
                    local buf = vim.fn.bufnr(body.frame.source.path)
                    local line = body.frame.line

                    if buf and line then
                        -- Apply the highlight
                        vim.api.nvim_buf_add_highlight(buf, -1, "DapStoppedLine", line - 1, 0, -1)

                        -- Place a sign (icon) in the sign column
                        vim.fn.sign_place(0, "DapStoppedGroup", "DapStopped", buf, { lnum = line, priority = 200 })
                    end
                end
            end

            -- Remove highlight and sign when continuing execution
            dap.listeners.before.event_continued["clear_stopped"] = function()
                vim.api.nvim_buf_clear_namespace(0, -1, 0, -1)
                vim.fn.sign_unplace("DapStoppedGroup")
            end

            dap.listeners.before.event_terminated["clear_stopped"] = function()
                vim.api.nvim_buf_clear_namespace(0, -1, 0, -1)
                vim.fn.sign_unplace("DapStoppedGroup")
            end
        end
    },


    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            local function layout(name)
                return {
                    elements = {
                        { id = name },
                    },
                    enter = true,
                    size = 40,
                    position = "right",
                }
            end
            local default = {
                elements = {
                    {
                        id = "scopes",
                        size = 0.5
                    },
                    {
                        id = "repl",
                        size = 0.5
                    } },
                position = "right",
                size = 50
            }

            local name_to_layout = {
                def = { layout = default, index = 0 },
                repl = { layout = layout("repl"), index = 0 },
                stacks = { layout = layout("stacks"), index = 0 },
                scopes = { layout = layout("scopes"), index = 0 },
                console = { layout = layout("console"), index = 0 },
                watches = { layout = layout("watches"), index = 0 },
                breakpoints = { layout = layout("breakpoints"), index = 0 },
            }
            local layouts = {}

            for name, config in pairs(name_to_layout) do
                table.insert(layouts, config.layout)
                name_to_layout[name].index = #layouts
            end

            local function toggle_debug_ui(name)
                dapui.close()
                local layout_config = name_to_layout[name]

                if layout_config == nil then
                    error(string.format("bad name: %s", name))
                end

                dapui.toggle(layout_config.index)
            end

            vim.keymap.set("n", "<leader>dd", function() toggle_debug_ui("def") end,
                { desc = "Debug: toggle repl+scopes ui" })
            vim.keymap.set("n", "<leader>dr", function() toggle_debug_ui("repl") end, { desc = "Debug: toggle repl ui" })
            vim.keymap.set("n", "<leader>ds", function() toggle_debug_ui("stacks") end,
                { desc = "Debug: toggle stacks ui" })
            vim.keymap.set("n", "<leader>dw", function() toggle_debug_ui("watches") end,
                { desc = "Debug: toggle watches ui" })
            vim.keymap.set("n", "<leader>db", function() toggle_debug_ui("breakpoints") end,
                { desc = "Debug: toggle breakpoints ui" })
            vim.keymap.set("n", "<leader>dS", function() toggle_debug_ui("scopes") end,
                { desc = "Debug: toggle scopes ui" })
            vim.keymap.set("n", "<leader>dc", function() toggle_debug_ui("console") end,
                { desc = "Debug: toggle console ui" })

            vim.api.nvim_create_autocmd("BufEnter", {
                group = "DapGroup",
                pattern = "*dap-repl*",
                callback = function()
                    vim.wo.wrap = true
                end,
            })

            vim.api.nvim_create_autocmd("BufWinEnter", create_nav_options("dap-repl"))
            vim.api.nvim_create_autocmd("BufWinEnter", create_nav_options("DAP Watches"))

            dapui.setup({
                layouts = layouts,
                enter = true,
            })

            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end

            dap.listeners.after.event_output.dapui_config = function(_, body)
                if body.category == "console" then
                    dapui.eval(body.output) -- Sends stdout/stderr to Console
                end
            end
        end,
    },

    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
            "neovim/nvim-lspconfig",
        },
        config = function()
            require("mason-nvim-dap").setup({
                ensure_installed = {
                    "delve",
                    "python", -- Add Python DAP
                    "node2",  -- Add Node.js DAP
                },
                automatic_installation = true,
                handlers = {
                    function(config)
                        require("mason-nvim-dap").default_setup(config)
                    end,
                    delve = function(config)
                        table.insert(config.configurations, 1, {
                            args = function() return vim.split(vim.fn.input("args> "), " ") end,
                            type = "delve",
                            name = "file",
                            request = "launch",
                            program = "${file}",
                            outputMode = "remote",
                        })
                        table.insert(config.configurations, 1, {
                            args = function() return vim.split(vim.fn.input("args> "), " ") end,
                            type = "delve",
                            name = "file args",
                            request = "launch",
                            program = "${file}",
                            outputMode = "remote",
                        })
                        require("mason-nvim-dap").default_setup(config)
                    end,
                },
            })
        end,
    },

    {
        "Weissle/persistent-breakpoints.nvim",
        config = function()
            local pb = require("persistent-breakpoints")
            local api = require("persistent-breakpoints.api")
            local dap = require("dap")
            local save_dir = vim.fn.stdpath('data') .. '/nvim_checkpoints'
            print(save_dir)
            pb.setup {
                save_dir = save_dir,
                -- when to load the breakpoints? "BufReadPost" is recommanded.
                load_breakpoints_event = "BufReadPost",
                -- record the performance of different function. run :lua require('persistent-breakpoints.api').print_perf_data() to see the result.
                --lua require('persistent-breakpoints.api').print_perf_data()
                perf_record = true,
                -- perform callback when loading a persisted breakpoint
                --- @param opts DAPBreakpointOptions options used to create the breakpoint ({condition, logMessage, hitCondition})
                --- @param buf_id integer the buffer the breakpoint was set on
                --- @param line integer the line the breakpoint was set on
                on_load_breakpoint = nil,
            }

            dap.listeners.after.event_exited.dapui_config = function()
                vim.defer_fn(function()
                    api.reload_breakpoints()
                end, 100)
            end

            vim.keymap.set("n", "<leader>b", "<cmd>lua require('persistent-breakpoints.api').toggle_breakpoint()<cr>",
                { desc = "Debug: Toggle Breakpoint" })
            vim.keymap.set("n", "<leader>B",
                "<cmd>lua require('persistent-breakpoints.api').set_conditional_breakpoint()<cr>")
        end,
    },
}

