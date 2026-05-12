return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- navigation
        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")

        -- actions
        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>gc", gs.undo_stage_hunk, "Cancel stage hunk")

        map("v", "<leader>gs", function() -- stage selected hunk
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage hunk")
        map("v", "<leader>gu", function() -- reset selected hunk
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset hunk")

        map("n", "<leader>gS", gs.stage_buffer, "Stage buffer") -- stage whole buffer
        map("n", "<leader>gU", gs.reset_buffer, "Unstage buffer") -- unstage whole buffer

        map("n", "<leader>gv", gs.preview_hunk, "Preview hunk")

        map("n", "<leader>gb", function()
          gs.blame_line({ full = true })
        end, "Blame line")
        map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle line blame")

        map("n", "<leader>gd", gs.diffthis, "Diff this")
        map("n", "<leader>gD", function()
          gs.diffthis("~")
        end, "Diff this ~")

        -- text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk")
      end,
    },
  },
  {
    "kdheepak/lazygit.nvim",
    enabled = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open lazy git" },
    },
  },
}
