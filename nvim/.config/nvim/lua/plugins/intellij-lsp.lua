-- intellij-lsp.nvim — JetBrains' IntelliJ language server for Java/Kotlin.
--
-- Enabled when java_lsp = "intellij" in .env.lua. The plugin doesn't go through
-- vim.lsp.enable(): calling setup() is what starts it. So it is lazy-loaded on
-- java/kotlin buffers (setup runs in `config` when lazy.nvim loads it) and a
-- placeholder 'intellij' config is registered so that
--   :lsp enable intellij    loads + starts it (attaches to open java/kotlin buffers)
--   :lsp disable intellij   stops the server and stops it auto-starting again
--
-- Licensing: :IntellijLspLicense (see :help intellij-lsp-licensing).

-- Each work file's root is resolved on demand (personal/work_root.lua): the checkout/worktree of
-- work_repo it lives in. Project view from work_project_view.

local NAME = "intellij" -- the client name the plugin uses

-- Bazel project view (shared with IntelliJ, gitignored, per-user). It decides
-- which directories/targets get synced and indexed — edit it to change scope.
local WORK_PROJECT_VIEW = vim.g.work_project_view or ".ijwb/user.bazelproject"

-- Without this, a file's root is its nearest pom.xml, widened to the root
-- pom's reactor: a Maven import of the whole repo. Pin every file in the
-- monorepo to the repo root so there is one server, importing with Bazel.
local function pin_work_root()
  local client = require("intellij-lsp.client")
  local work_root = require("personal.work_root")
  local find_root, find_build_root = client.find_root, client.find_build_root
  client.find_root = function(bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr)
    local root = name ~= "" and not client.is_uri_name(name) and work_root(name)
    if root then
      return root
    end
    return find_root(bufnr)
  end
  client.find_build_root = function(cwd)
    local root = work_root(cwd)
    if root then
      return root
    end
    return find_build_root(cwd)
  end
end

local opts -- resolved opts, kept for re-enabling after :lsp disable

return {
  "JetBrains/intellij-lsp.nvim",
  enabled = vim.g.java_lsp == "intellij",
  ft = { "java", "kotlin" },
  dependencies = { "mfussenegger/nvim-dap" }, -- optional: run and debug
  opts = function()
    local o = {
      colorscheme = false, -- keep my own colorscheme
      -- The 2 GB default heap is too small for a repo this size.
      jvm_args = { "-Xmx8g" },
    }
    local root = require("personal.work_root")(vim.fn.getcwd())
    if root then
      o.build_tool = "bazel" -- never fall back to the root pom.xml
      o.projects = {
        {
          type = "bazel",
          path = vim.uri_from_fname(root),
          projectPath = WORK_PROJECT_VIEW, -- relative to the root
        },
      }
    end
    return o
  end,
  config = function(_, o)
    opts = o
    pin_work_root()
    require("intellij-lsp").setup(opts)
  end,
  init = function()
    -- Placeholder so `:lsp enable` knows (and completes) the name. Core never
    -- starts it itself: empty filetypes means its FileType handler never matches.
    vim.lsp.config(NAME, {
      cmd = { "intellij-server" },
      filetypes = {},
    })

    local enable = vim.lsp.enable
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.lsp.enable = function(name, on)
      enable(name, on)
      local names = type(name) == "table" and name or { name }
      if not vim.list_contains(names, NAME) then
        return
      end
      if on == false then
        pcall(vim.api.nvim_del_augroup_by_name, "IntellijLsp")
        for _, client in ipairs(vim.lsp.get_clients({ name = NAME })) do
          client:stop()
        end
      elseif opts then
        require("intellij-lsp").setup(opts) -- already loaded: re-arm after a disable
      else
        require("lazy").load({ plugins = { "intellij-lsp.nvim" } })
      end
    end
  end,
}
