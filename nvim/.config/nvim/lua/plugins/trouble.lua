return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
  cmd = "Trouble",
  keys = {
    {
      "<leader>xd",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Trouble: workspace diagnostics",
    },

    {
      "<leader>xf",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Trouble: document diagnostics",
    },

    {
      "<leader>xc",
      "<cmd>Trouble todo toggle<cr>",
      desc = "Trouble: open todos in trouble",
    },

    {
      "<leader>xq",
      "<cmd>Trouble quickfix toggle<cr>",
      desc = "Trouble: open quickfix toggle",
    },

    {
      "<leader>xt",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "Trouble: LSP definitions/refs",
    },

    {
      "<leader>xl",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Trouble: open location list",
    },
  },

  opts = {
    modes = {
      diagnostics = { auto_close = true },
    },
  },
}
