local lspconfig = require('lspconfig')
local lspformat = require('lsp-format')
lspformat.setup({})

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

-- Add cmp_nvim_lsp capabilities settings to lspconfig
-- This should be executed before you configure any language server
local lspconfig_defaults = lspconfig.util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

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
  end
})

-- Setup mason
require('mason').setup({})
require("mason-lspconfig").setup({
  ensure_installed = { "ts_ls", "eslint", "efm", "jdtls" },
  automatic_installation = true,
  handlers = {
    function(server_name)
      lspconfig[server_name].setup({})
    end,
    jdtls = function()
      -- Custom handler for jdtls to ensure it's properly configured
      lspconfig.jdtls.setup({
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
    end,
  },
})

lspconfig.eslint.setup({
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
})

lspconfig.denols.setup({
  root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
  init_options = {
    enable = true,
    lint = true,
    unstable = true,
    importMap = "./deno.json"
  }
})

lspconfig.ts_ls.setup({
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = false
  end,
  single_file_support = false,
  root_dir = function(fname)
    local deno_root = lspconfig.util.root_pattern("deno.json", "deno.jsonc")(fname)
    if deno_root then
      return nil -- Return nil to tell tsserver not to attach in Deno projects
    end
    return lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json")(fname)
  end,
  init_options = {
    preferences = {
      includeInlayParameterNameHints = 'all',
      includeInlayParameterNameHintsWhenArgumentMatchesName = true,
      includeInlayFunctionParameterTypeHints = true,
      includeInlayVariableTypeHints = true,
      includeInlayVariableTypeHintsWhenTypeMatchesName = true,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = true,
      includeInlayEnumMemberValueHints = true,
    },
  },
})

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
lspconfig.efm.setup {
  on_attach = function(client)
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_command('autocmd BufWritePre <buffer> lua vim.lsp.buf.format()')
    end
  end,
  init_options = { documentFormatting = not work_dir },
  root_dir = function(fname)
    return lspconfig.util.root_pattern('.prettierrc', '.prettierrc.js', '.git')(fname) or vim.loop.cwd()
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
}

lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = { library = vim.api.nvim_get_runtime_file('', true) },
      telemetry = { enable = false },
    },
  },
})

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
