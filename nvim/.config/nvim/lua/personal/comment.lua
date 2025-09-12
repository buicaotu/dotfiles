-- workaround until this is supported in nvim core in nvim 0.11
-- https://github.com/neovim/neovim/issues/28830#issuecomment-2119690661
-- https://github.com/neovim/neovim/pull/30501
local get_option = vim.filetype.get_option
vim.filetype.get_option = function(filetype, option)
  return option == "commentstring"
      and require("ts_context_commentstring.internal").calculate_commentstring()
      or get_option(filetype, option)
end
