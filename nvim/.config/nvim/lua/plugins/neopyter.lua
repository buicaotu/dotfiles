-- Lazily built so that nvim-treesitter-textobjects is loaded before we require it.
local cell_move
local function get_cell_move()
    if not cell_move then
        local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
        cell_move = ts_repeat_move.make_repeatable_move(function(opts)
            vim.fn.search([[^# %%]], opts.forward and "W" or "bW")
        end)
    end
    return cell_move
end

return {
    "SUSTech-data/neopyter",
    dependencies = {
      'AbaoFromCUG/websocket.nvim',  -- for mode='direct'
    },

    opts = {
        mode="direct",
        remote_address = "127.0.0.1:8989",
        file_pattern = { "*.ju.*" },
        on_attach = function(bufnr)
            local map = function(lhs, rhs, desc)
                vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
            end
            map("<leader>jr", "<cmd>Neopyter run current<cr>", "Neopyter: run current cell")
            map("<leader>ja", "<cmd>Neopyter run all<cr>", "Neopyter: run all cells")
            map("<leader>ju", "<cmd>Neopyter run allAbove<cr>", "Neopyter: run cells above")
            map("<leader>jd", "<cmd>Neopyter run allBelow<cr>", "Neopyter: run cells below")
            map("<leader>jn", function() get_cell_move()({ forward = true }) end, "Neopyter: next cell")
            map("<leader>jp", function() get_cell_move()({ forward = false }) end, "Neopyter: prev cell")
            map("<leader>ji", function()
                -- find next cell and add a cell above it; otherwise append at end of file
                local lnum = vim.fn.search([[^# %%]], "W")
                if lnum > 0 then
                    vim.api.nvim_buf_set_lines(0, lnum - 1, lnum - 1, false, { "# %%", "" })
                    vim.api.nvim_win_set_cursor(0, { lnum + 1, 0 })
                else
                    local last = vim.api.nvim_buf_line_count(0)
                    vim.api.nvim_buf_set_lines(0, last, last, false, { "# %%", "" })
                    vim.api.nvim_win_set_cursor(0, { last + 2, 0 })
                end
                vim.cmd.startinsert()
            end, "Neopyter: insert cell")

            vim.api.nvim_buf_create_user_command(bufnr, "SetUpIpynbIfMissing", function()
                local current = vim.api.nvim_buf_get_name(bufnr)
                if current == "" then
                    vim.notify("buffer has no file name", vim.log.levels.WARN)
                    return
                end
                local dir = vim.fn.fnamemodify(current, ":h")
                local name = vim.fn.fnamemodify(current, ":t")
                local base = name:match("^(.-)%.ju%.[^.]+$")
                if not base then
                    vim.notify(name .. " does not match *.ju.*", vim.log.levels.WARN)
                    return
                end
                local ipynb = dir .. "/" .. base .. ".ipynb"
                if vim.fn.filereadable(ipynb) == 1 then
                    vim.notify(ipynb .. " already exists")
                    return
                end
                vim.fn.writefile({
                    '{',
                    ' "cells": [],',
                    ' "metadata": {},',
                    ' "nbformat": 4,',
                    ' "nbformat_minor": 5',
                    '}',
                }, ipynb)
                vim.notify("created " .. ipynb)
                vim.cmd("Neopyter sync " .. vim.fn.fnameescape(base .. ".ipynb"))
            end, { desc = "Create matching .ipynb if missing" })
        end,
    },
}
