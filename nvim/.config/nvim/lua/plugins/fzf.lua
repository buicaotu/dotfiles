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
    }
  },
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
        "<leader>r",
        function()
          local selected_text = require("fzf-lua.utils").get_visual_selection()
          vim.cmd.Rg(selected_text)
        end,
        desc = "Grep visual selection",
        mode = "v",
      },
      {
        "<leader>R",
        function()
          vim.cmd.OilGrep(vim.fn.expand("<cword>"))
        end,
        desc = "Grep in current directory",
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
        "<leader>rf",
        function()
          local selected_text = require("fzf-lua.utils").get_visual_selection()
          vim.cmd.Rf(selected_text)
        end,
        desc = "Grep selection in quickfix",
        mode = "v",
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
        "<leader>rb",
        function()
          local selected_text = require("fzf-lua.utils").get_visual_selection()
          vim.cmd.Rb(selected_text)
        end,
        desc = "Grep selection in buffers",
        mode = "v",
      },
      {
        "<leader>s",
        function()
          vim.cmd.FzfLua('files')
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
      { "<leader>p", vim.cmd.FzfLua, desc = "FzfLua", mode = "n" },
      {
        "<leader>lf",
        function()
          vim.cmd.FzfLua('quickfix')
        end,
        desc = "Quickfix list",
        mode = "n",
      },
    })

    -- todo: grep selected word/word under cursor within current folder

    -- Setup FZF Vim commands
    -- require("fzf-lua").setup_fzfvim_cmds()

    -- Create :Rg command for searching
    vim.api.nvim_create_user_command("Rg", function(opts)
      local search_text = table.concat(opts.fargs, " ")
      if vim.bo.filetype == "oil" then
        vim.cmd.OilGrep(search_text)
      else
        require("personal.command_palette").grep(vim.fn.getcwd(), search_text)
      end
    end, { nargs = "*" })

    -- Create :Rf command for searching in quickfix files
    vim.api.nvim_create_user_command("Rf", function(opts)
      local search_text = table.concat(opts.fargs, " ")
      require("fzf-lua").grep_quickfix({
        search = search_text,
        input_prompt = 'Grep in quickfix files ❯ ',
      })
    end, { nargs = "*" })

    -- Create :Rb command for searching in buffer files
    vim.api.nvim_create_user_command("Rb", function(opts)
      local search_text = table.concat(opts.fargs, " ")
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
    end, { nargs = "*" })
  end
}
