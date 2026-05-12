return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")

      autopairs.setup({
        check_ts = true, -- use treesitter
        ts_config = {
          lua = { "string" }, -- don't add pairs in lua strings
          javascript = { "template_string" },
          java = false, -- disable TS for java
        },
        disable_filetype = { "TelescopePrompt", "vim" },
        fast_wrap = {
          map = "<C-w>", --  INFO: ctrl+w for fast wrap in insert mode
          chars = { "{", "[", "(", '"', "'" },
          pattern = [=[[%'%"%>%]%)%}%,]]=],
          end_key = "$",
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          check_comma = true,
          highlight = "Search",
          highlight_grey = "Comment",
        },
      })

      -- blink.cmp integration
      require("nvim-autopairs.completion.handlers").blink = {
        kind_to_handler = {},
      }
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
      })
    end,
  },
}
