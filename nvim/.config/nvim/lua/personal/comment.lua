-- Context-aware commentstring via ts_context_commentstring.
-- enable_autocmd = false so the plugin doesn't set up its own CursorHold on every buffer.
-- We hook into vim.filetype.get_option instead, which only fires when commentstring is needed.
local get_option = vim.filetype.get_option
vim.filetype.get_option = function(filetype, option)
  if option == "commentstring" then
    local ok, cs = pcall(require("ts_context_commentstring.internal").calculate_commentstring)
    if ok and cs then return cs end
  end
  return get_option(filetype, option)
end
