-- fff.nvim — a Rust-backed file index with a fast programmatic content grep.
--
-- We don't use fff's own picker UI. Instead the :RR command runs an interactive
-- content (text) search rendered inside an fzf-lua window, so all the usual
-- fzf-lua actions, preview and keymaps apply (just like the rest of the setup in
-- fzf.lua), while fff drives the grep.
--
-- How the integration works:
--   * fzf-lua "live" mode calls our function on every keystroke with the typed
--     query (the selection table's first element); we run fff.content_search and
--     stream the matches straight to fzf.
--   * fzf's own fuzzy matching is disabled in live mode, and we add --no-sort so
--     fzf preserves fff's match ordering instead of re-ranking it.
--   * each match is emitted as `relative_path:line:col:text` so fzf-lua's builtin
--     previewer shows the file on the right scrolled to the match, and <enter>/
--     split/etc. open at the matched line. fff returns paths relative to its
--     indexed base_path, so we point fzf-lua's `cwd` there to resolve them.

return {
  "dmtrKovalenko/fff.nvim",
  build = function()
    require("fff.download").download_or_build_binary()
  end,
  dependencies = { "ibhagwan/fzf-lua" },
  lazy = false, -- keep the index warm so :RR is instant
  opts = {},
  config = function(_, opts)
    require("fff").setup(opts)

    local fzf = require("fzf-lua")

    -- Reuse the user's resolved file actions (enter/split/vsplit/tabedit/qf), but
    -- drop the toggle_* binds which depend on fzf-lua's own file-finder internals
    -- and don't apply to a custom live source.
    local function file_actions()
      local actions = vim.deepcopy(require("fzf-lua.config").globals.actions.files or {})
      actions["alt-i"] = nil -- toggle_ignore
      actions["alt-h"] = nil -- toggle_hidden
      actions["alt-f"] = nil -- toggle_follow
      return actions
    end

    local function fff_grep(o)
      o = o or {}
      o.prompt = o.prompt or "FFF grep❯ "
      -- fff results are relative to its indexed root; resolve actions/preview
      -- against it, and show the builtin preview on the right like fzf.lua grep.
      o.cwd = o.cwd or require("fff.conf").get().base_path or vim.uv.cwd()
      o.previewer = o.previewer or "builtin"
      o.actions = o.actions or file_actions()
      o.fzf_opts = vim.tbl_extend("keep", o.fzf_opts or {}, {
        ["--no-sort"] = true, -- keep fff's match ordering, don't let fzf re-sort
      })

      local search_opts = {
        mode = o.mode or "plain", -- "plain" | "regex" | "fuzzy"
        page_size = o.page_size or 100,
      }

      -- fzf-lua passes the live callback the selection table; the typed query is
      -- its first element (matching the {q} field index).
      return fzf.fzf_live(function(args)
        local query = type(args) == "table" and args[1] or (type(args) == "string" and args)
        if not query or query == "" then return {} end
        local result = require("fff").content_search(query, search_opts)
        local lines = {}
        for _, item in ipairs(result.items or {}) do
          if not item.is_binary_content then
            lines[#lines + 1] = string.format(
              "%s:%d:%d:%s",
              item.relative_path,
              item.line_number or 0,
              (item.col or 0) + 1,
              item.line_content or ""
            )
          end
        end
        return lines
      end, o)
    end

    vim.api.nvim_create_user_command("RR", function()
      fff_grep()
    end, { desc = "fff content (text) search, rendered in fzf-lua" })
  end,
}
