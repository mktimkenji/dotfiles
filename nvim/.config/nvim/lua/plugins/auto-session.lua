return {
  "rmagatti/auto-session",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    local auto_session = require("auto-session")

    auto_session.setup({
      auto_restore = false,
      suppressed_dirs = { "~/Desktop", "~/Documents", "~/Downloads", "~/Games", "~/Heroic" },
      session_lens = { load_on_setup = true },
    })

    vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

    local keymap = vim.keymap

    keymap.set("n", "<leader>wr", ":AutoSession restore<CR>", { desc = "Restore session" })
    keymap.set("n", "<leader>ws", ":AutoSession save<CR>", { desc = "Save session" })
    keymap.set("n", "<leader>wl", ":Telescope session-lens search_session<CR>", { desc = "Search sessions" })
  end,
}
