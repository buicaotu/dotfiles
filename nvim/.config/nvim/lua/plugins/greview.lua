return {
  dir = "/Users/tu/proj/greview",
  name = "greview",
  lazy = false,
  config = function()
    require("greview").setup({
      log_level = "debug",
    })
  end,
}
