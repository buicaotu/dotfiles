-- Function to get all files from open buffers
local function get_buffer_files()
  local files = {}
  local buffers = vim.api.nvim_list_bufs()

  for _, bufnr in ipairs(buffers) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype == '' then
      local file_path = vim.api.nvim_buf_get_name(bufnr)
      if file_path ~= '' and not files[file_path] then
        files[file_path] = true
      end
    end
  end

  local file_list = {}
  for file, _ in pairs(files) do
    table.insert(file_list, file)
  end

  return file_list
end

-- a function to check if the current buffer is in a float window
local function is_floating_window()
  local win_config = vim.api.nvim_win_get_config(0)
  return win_config.relative ~= ''
end

-- Grep function that handles searching with fzf-lua
-- @param opts Command options (from vim.api.nvim_create_user_command)
--   - opts.range: >0 if called from visual mode
--   - opts.fargs: command arguments array
-- @param grep_opts Grep-specific options
--   - grep_opts.no_esc: if true, disables escaping of special characters in search pattern
-- Behavior:
--   - In oil buffers: searches within the current directory, closes floating oil window if open,
--     and adds the command to command history
--   - In regular buffers: uses fzf-lua's grep function directly
--   - Visual mode: searches for selected text
--   - Normal mode: searches for command arguments
local function grep(opts, grep_opts)
  local search_text
  if opts.range > 0 then
    -- Visual mode: get selected text
    search_text = require("fzf-lua.utils").get_visual_selection()
  else
    -- Normal mode: use command arguments
    search_text = table.concat(opts.fargs, " ")
  end

  if vim.bo.filetype == "oil" then
    local oil = require("oil");
    local dir = oil.get_current_dir() or vim.fn.expand("%:p:h")
    if vim.bo.filetype == "oil" and is_floating_window() then
      oil.close()
    end
    local grep_opts_string = grep_opts.no_esc and "no_esc=true" or ""
    local cmd_string = string.format('FzfLua grep search=%s cwd=%s %s', search_text:gsub(" ", "\\ "), dir, grep_opts_string)
    vim.cmd(cmd_string)
    vim.fn.histadd('cmd', cmd_string)
  else
    require("fzf-lua").grep({
      search = search_text,
      no_esc = grep_opts.no_esc,
    })
  end
end

return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    "hide",
    winopts = {
      preview = { hidden = "nohidden" },
    },
    files = {
      -- disable previewer for file search only
      previewer = false,
      git_icons = false,
    },
    buffers = {
      previewer = false,
      git_icons = false,
    },
    oldfiles = {
      previewer = false,
    },
    previewers = {
      syntax_limit_b = 1024 * 100, -- 100KB
    },
    grep = {
      rg_glob = true,
      glob_flag = "--iglob",     -- for case sensitive globs use '--glob'
      glob_separator = "%s%-%-", -- query separator pattern (lua): ' --'
      -- adding "--with-filename" to the default grep rg_opts
      rg_opts = "--column --line-number --no-heading --with-filename --color=always --smart-case --max-columns=4096 -e"
    },
    olfildes = {
      include_current_session = false,
    }
  },
  config = function(_, opts)
    local fzflua = require("fzf-lua")
    fzflua.setup(opts)
    fzflua.register_ui_select()
  end,
  init = function()
    -- FZF settings
    vim.env.FZF_DEFAULT_COMMAND = 'fd --type file --follow --hidden --exclude .git'
    vim.g.fzf_history_dir = '~/.local/share/fzf-history'

    local wk = require("which-key")
    wk.add({
      { "<leader>r", group = "Grep/Search" },
      {
        "<leader>r",
        function()
          vim.cmd.Rg(vim.fn.expand("<cword>"))
        end,
        desc = "Grep word under cursor",
        mode = "n",
      },
      {
        "<leader>rf",
        function()
          vim.cmd.Rf(vim.fn.expand("<cword>"))
        end,
        desc = "Grep in quickfix files",
        mode = "n",
      },
      {
        "<leader>rb",
        function()
          vim.cmd.Rb(vim.fn.expand("<cword>"))
        end,
        desc = "Grep in buffer files",
        mode = "n",
      },
      {
        "<leader>s",
        function()
          vim.cmd.Files()
        end,
        desc = "Find files",
        mode = "n",
      },
      {
        "<C-p>",
        function()
          vim.cmd.FzfLua('buffers')
        end,
        desc = "Find buffers",
        mode = "n",
      },
      {
        "<A-p>",
        function()
          vim.cmd.FzfLua('global')
        end,
        desc = "Fzf global",
        mode = "n",
      },
      {
        "<leader>p",
        vim.cmd.FzfLua,
        desc = "FzfLua",
        mode = "n"
      },
      {
        "<leader>lf",
        function()
          vim.cmd.FzfLua('quickfix')
        end,
        desc = "Quickfix list",
        mode = "n",
      },
      {
        "<C-x><C-f>",
        function()
          vim.cmd.FzfLua('complete_path')
        end,
        desc = "Fzf complete path",
        mode = { "i", "n", "v" },
      },
      {
        "<C-x><C-r>",
        function()
          vim.cmd.FzfLua('registers')
        end,
        desc = "Fzf complete register",
        mode = { "i", "n", "v" },
      },
    })

    -- Create :Rg command for searching
    -- The command will search using fzf-lua's grep function
    -- if the current buffer is an oil buffer, it will create a grep command to search within the current directory
    -- and add the command to the command history
    vim.api.nvim_create_user_command("Rg", function(opts)
      grep(opts, { no_esc = false })
    end, { nargs = "*", range = true })
    vim.api.nvim_create_user_command("RG", function(opts)
      grep(opts, { no_esc = true })
    end, { nargs = "*", range = true })

    -- Create :Rf command for searching in quickfix files
    vim.api.nvim_create_user_command("Rf", function(opts)
      local search_text
      if opts.range > 0 then
        -- Visual mode: get selected text
        search_text = require("fzf-lua.utils").get_visual_selection()
      else
        -- Normal mode: use command arguments
        search_text = table.concat(opts.fargs, " ")
      end

      require("fzf-lua").grep_quickfix({
        search = search_text,
        input_prompt = 'Grep in quickfix files ❯ ',
      })
    end, { nargs = "*", range = true })

    -- Create :Rb command for searching in buffer files
    vim.api.nvim_create_user_command("Rb", function(opts)
      local search_text
      if opts.range > 0 then
        -- Visual mode: get selected text
        search_text = require("fzf-lua.utils").get_visual_selection()
      else
        -- Normal mode: use command arguments
        search_text = table.concat(opts.fargs, " ")
      end

      -- Get files from open buffers
      local buffer_files = get_buffer_files()

      if #buffer_files == 0 then
        vim.notify("No valid buffer files found", vim.log.levels.WARN)
        return
      end

      require("fzf-lua").grep({
        search = search_text,
        input_prompt = 'Grep in buffer files ❯ ',
        search_paths = buffer_files,
      })
    end, { nargs = "*", range = true })

    -- Files
    vim.api.nvim_create_user_command("Files", function(opts)
      if vim.bo.filetype == "oil" then
        local oil = require("oil");
        local dir = oil.get_current_dir() or vim.fn.expand("%:p:h")
        if vim.bo.filetype == "oil" then
          oil.close()
        end
        local cmd_string = string.format('FzfLua files cwd=%s', dir)
        vim.cmd(cmd_string)
        vim.fn.histadd('cmd', cmd_string)
      else
        vim.cmd.FzfLua('files')
      end
    end, { nargs = "*", range = true })

    -- Directories
    vim.api.nvim_create_user_command("Directories", function(opts)
      require 'fzf-lua'.fzf_exec('fd --type directory --hidden --follow --exclude .git', {
        actions = {
          ['default'] = function(selected)
            -- vim.cmd('cd ' .. vim.fn.fnameescape(selected[1]))
            vim.notify('Changed directory to ' .. selected[1], vim.log.levels.INFO)
            local string_cmd = string.format('Oil --float %s', vim.fn.fnameescape(selected[1]))
            vim.cmd(string_cmd)
            vim.fn.histadd('cmd', string_cmd)
          end,
        },
      })
    end, { nargs = "*", range = true })
  end
}
