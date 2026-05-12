return {
  {
    "nvim-mini/mini.comment",
    version = false,
    config = function()
      require("mini.comment").setup()
    end,
  },
  {
    "nvim-mini/mini.surround",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      custom_surroundings = nil,
      highlight_duration = 300,

      -- INFO:
      -- saiw surround with no whitespace
      -- saw surround with whitespace
      -- module mappings, use `''` (empty string) to disable one.
      mappings = {
        add = "sa", -- add surrounding in Normal and Visual modes
        delete = "ds", -- delete surrounding
        find = "sf", -- find surrounding (to the right)
        find_left = "sF", -- find surrounding (to the left)
        highlight = "sh", -- highlight surrounding
        replace = "sr", -- replace surrounding
        update_n_lines = "sn", -- update `n_lines`

        suffix_last = "l", -- suffix to search with "prev" method
        suffix_next = "n", -- nuffix to search with "next" method
      },

      n_lines = 20,
      respect_selection_type = false,
      search_method = "cover",
      silent = false,
    },
  },
  {
    "nvim-mini/mini.splitjoin",
    config = function()
      local miniSplitJoin = require("mini.splitjoin")
      miniSplitJoin.setup({
        mappings = { toggle = "" }, -- disable default mapping
      })
      vim.keymap.set({ "n", "x" }, "sj", function()
        miniSplitJoin.join()
      end, { desc = "Join arguments" })
      vim.keymap.set({ "n", "x" }, "sk", function()
        miniSplitJoin.split()
      end, { desc = "Split arguments" })
    end,
  },
}
