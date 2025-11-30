local lspformat = require('lsp-format')
local lsp_util = require('lspconfig.util')
local cmp_capabilities = require('cmp_nvim_lsp').default_capabilities()
lspformat.setup({})

vim.lsp.config('*', {
  capabilities = cmp_capabilities,
})

-- Diagnostics
local virtual_configs = {
  virtual_text = { current_line = true, severity = { min = "INFO" } },
  virtual_lines = false
}
local virtual_configs_lines = {
  virtual_text = { current_line = true, severity = { min = "INFO", max = "WARN" } },
  virtual_lines = { current_line = false, severity = { min = "ERROR" } }
}
vim.diagnostic.config({
  signs = { priority = 9999 },
  underline = true,
  update_in_insert = false, -- false so diags are updated on InsertLeave
  virtual_text = virtual_configs.virtual_text,
  virtual_lines = virtual_configs.virtual_lines,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = true,
    header = "",
  },
})
local wk = require("which-key")
wk.add({
  { "<leader>l", group = "LSP" },
  {
    "<leader>le",
    function()
      vim.diagnostic.setqflist({ severity = { min = "ERROR" } })
    end,
    desc = "List errors in quickfix",
    mode = "n",
  },
})

-- Capabilities are set globally via vim.lsp.config('*') above.

-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    -- Keymaps
    local wk = require("which-key")
    wk.add({
      { "g",  group = "Go to",            buffer = event.buf },
      { "gD", vim.lsp.buf.declaration,    desc = "Go to declaration",     buffer = event.buf, mode = "n" },
      { "gd", vim.lsp.buf.definition,     desc = "Go to definition",      buffer = event.buf, mode = "n" },
      { "K",  vim.lsp.buf.hover,          desc = "Hover documentation",   buffer = event.buf, mode = "n" },
      { "gi", vim.lsp.buf.implementation, desc = "Go to implementation",  buffer = event.buf, mode = "n" },
      { "gr", vim.lsp.buf.references,     desc = "Go to references",      buffer = event.buf, mode = "n" },
      { "gk", vim.lsp.buf.signature_help, desc = "Signature help",        buffer = event.buf, mode = "n" },
      { "gl", vim.diagnostic.open_float,  desc = "Show line diagnostics", buffer = event.buf, mode = "n" },
      {
        "<leader>ll",
        function()
          -- toggle virtual lines
          local has_virtual_lines = vim.diagnostic.config().virtual_lines ~= false
          if (has_virtual_lines) then
            vim.diagnostic.config(virtual_configs)
          else
            vim.diagnostic.config(virtual_configs_lines)
          end
        end,
        desc = "Toggle virtual lines",
        buffer = event.buf,
        mode = "n",
      },
      {
        "<F2>",
        vim.lsp.buf.rename,
        desc = "Rename symbol",
        buffer = event.buf,
        mode = "n"
      },
      {
        "<leader>ld",
        vim.lsp.buf.type_definition,
        desc = "Type definition",
        buffer = event.buf,
        mode = "n"
      },
      {
        "<leader>lca",
        vim.lsp.buf.code_action,
        desc = "Code action",
        buffer = event.buf,
        mode = "n"
      },
      {
        "<leader>lf",
        function()
          vim.lsp.buf.format { async = true }
        end,
        desc = "Lsp Format buffer",
        buffer = event.buf,
        mode = "n",
      },
    })

    local client = event.data and vim.lsp.get_client_by_id(event.data.client_id)
    if client and (client.name == "ts_ls" or client.name == "tsgo") then
      -- Prefer external formatters (efm/prettier/eslint) over ts language servers.
      client.server_capabilities.documentFormattingProvider = false
    end
  end
})

-- Setup mason
require('mason').setup({})
require("mason-lspconfig").setup({
  ensure_installed = { "ts_ls", "tsgo", "eslint", "efm" },
  automatic_enable = false,
  automatic_installation = true,
})

local eslint_base_cfg = vim.deepcopy(vim.lsp.config.eslint or {})
local eslint_base_on_attach = eslint_base_cfg.on_attach
vim.lsp.config('eslint', vim.tbl_extend("force", eslint_base_cfg, {
  on_attach = function(client, bufnr)
    if eslint_base_on_attach then
      eslint_base_on_attach(client, bufnr)
    end
    local group = vim.api.nvim_create_augroup("eslint_fix_all_" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      group = group,
      command = "LspEslintFixAll",
    })
  end,
}))

vim.lsp.config('jdtls', {
  cmd = {
    "/opt/homebrew/opt/openjdk@21/bin/java",
    "-Dlog.level=WARN",
    "--add-opens=java.base/java.lang=ALL-UNNAMED",
    "--add-opens=java.base/java.lang.reflect=ALL-UNNAMED",
    "--add-opens=java.base/java.io=ALL-UNNAMED",
    "--add-opens=java.base/java.util=ALL-UNNAMED",
    "--add-opens=java.base/java.util.concurrent=ALL-UNNAMED",
    "-jar", vim.fn.glob(vim.fn.stdpath("data") ..
    "/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
    "-configuration", vim.fn.stdpath("data") .. "/mason/packages/jdtls/config_mac",
    "-data", vim.fn.stdpath("cache") .. "/jdtls/workspace"
  },
  settings = {
    java = {
      maven = {
        downloadSources = true,
        updateSnapshots = true,
      },
      saveActions = {
        organizeImports = true,
      },
      completion = {
        favoriteStaticMembers = {
          "org.junit.jupiter.api.Assertions.*",
          "org.junit.jupiter.api.Assumptions.*",
          "org.mockito.Mockito.*",
          "org.mockito.ArgumentMatchers.*",
        },
        importOrder = {
          "java",
          "javax",
          "com",
          "org",
        },
      },
    },
  },
})

vim.lsp.config('denols', {
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname == "" then
      return
    end

    local root = lsp_util.root_pattern("deno.json", "deno.jsonc")(fname)
    if root then
      on_dir(root)
    end
  end,
  init_options = {
    enable = true,
    lint = true,
    unstable = true,
    importMap = "./deno.json"
  }
})

local ts_inlay_prefs = {
  includeInlayParameterNameHints = 'all',
  includeInlayParameterNameHintsWhenArgumentMatchesName = true,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHints = true,
  includeInlayVariableTypeHintsWhenTypeMatchesName = true,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}

local function ts_root_dir(bufnr, on_dir)
  local root_markers = { "package.json", "tsconfig.json", "jsconfig.json" }
  local deno_path = vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc', 'deno.lock' })
  local project_root = vim.fs.root(bufnr, root_markers)
  if deno_path and (not project_root or #deno_path >= #project_root) then
    return
  end
  -- We fallback to the current working directory if no project root is found
  on_dir(project_root or vim.fn.getcwd())
end

vim.lsp.config('ts_ls', {
  init_options = {
    preferences = ts_inlay_prefs,
  },
  root_dir = ts_root_dir,
})

vim.lsp.config('tsgo', {
  init_options = {
    preferences = ts_inlay_prefs,
  },
  root_dir = ts_root_dir,
})

-- Keep tsgo disabled by default; enable manually with vim.lsp.enable('tsgo')
vim.lsp.enable('tsgo', false)
vim.api.nvim_create_user_command("LspSwitchTs", function()
  local ts_ls_enabled = vim.lsp.is_enabled("ts_ls")

  if ts_ls_enabled then
    vim.lsp.enable("ts_ls", false)
    vim.lsp.enable("tsgo", true)
    vim.notify("Switched to tsgo (ts_ls disabled)", vim.log.levels.INFO)
  else
    vim.lsp.enable("tsgo", false)
    vim.lsp.enable("ts_ls", true)
    vim.notify("Switched to ts_ls (tsgo disabled)", vim.log.levels.INFO)
  end

  if vim.v.vim_did_enter == 1 then
    vim.cmd.doautoall('nvim.lsp.enable FileType')
  end
end, { desc = "Toggle between ts_ls and tsgo LSPs" })

local prettier = {
  formatCommand = "./node_modules/.bin/prettier --stdin-filepath ${INPUT}",
  formatStdin = true,
}
local prettier_work = {
  formatCommand = "./web/node_modules/.bin/prettier --stdin-filepath ${INPUT}",
  formatStdin = true,
}

local web_formatter = prettier
local work_dir = vim.fn.getcwd():find(vim.fn.expand("~") .. "/work") == 1
if work_dir then
  web_formatter = prettier_work
else
  web_formatter = prettier
end

-- Set up efm-langserver
vim.lsp.config('efm', {
  on_attach = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format()
        end,
      })
    end
  end,
  init_options = { documentFormatting = not work_dir },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root = fname ~= "" and lsp_util.root_pattern('.prettierrc', '.prettierrc.js', '.git')(fname) or nil
    on_dir(root or vim.uv.cwd())
  end,
  settings = {
    rootMarkers = { ".prettierrc", ".prettierrc.js", "dprint.json" },
    languages = {
      javascript = { web_formatter },
      typescript = { web_formatter },
      javascriptreact = { web_formatter },
      typescriptreact = { web_formatter },
      html = { web_formatter },
      markdown = { web_formatter },
      json = { web_formatter },
    },
  },
  filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  timeout_ms = 10000,
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = { library = vim.api.nvim_get_runtime_file('', true) },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.enable({ 'ts_ls', 'denols', 'eslint', 'efm', 'lua_ls', 'jdtls' })

-- Diagnostic navigation with repeat support
local ts_repeat_move_status, ts_repeat_move = pcall(require, "nvim-treesitter.textobjects.repeatable_move")
if ts_repeat_move_status then
  -- Register the diagnostic navigation functions with repeatable_move
  local next_diagnostic, prev_diagnostic = ts_repeat_move.make_repeatable_move_pair(
  -- maybe set severity to min = WARN.
    function()
      vim.diagnostic.jump({ count = 1, float = false })
    end,
    function()
      vim.diagnostic.jump({ count = -1, float = false })
    end
  )

  -- Map the diagnostic navigation to use repeatable_move
  wk.add({
    { "]d", next_diagnostic, desc = "Next diagnostic",     mode = "n" },
    { "[d", prev_diagnostic, desc = "Previous diagnostic", mode = "n" },
  })
end
