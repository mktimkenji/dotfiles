return {
  {
    "nvim-lua/plenary.nvim", -- core lua dependency for plugins
  },
  {
    "christoomey/vim-tmux-navigator", -- tmux & split windows navigation
  },
  {
    "folke/which-key.nvim", -- keybind hints
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 500
    end,
    opts = {},
  },
  {
    "folke/todo-comments.nvim", -- highlight todo comments
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "brenoprata10/nvim-highlight-colors", -- color highlighter
    config = function()
      require("nvim-highlight-colors").setup({})
    end,
  },
}
