return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    config = function()
      local ufo = require("ufo")
      ufo.setup({
        -- treesitter as the main provider
        provider_selector = function(_, _, _)
          return { "treesitter", "indent" }
        end,
        open_fold_hl_timeout = 0, -- disable highlight timeout after opening
      })

      vim.o.foldenable = true
      vim.o.foldcolumn = "0"
      vim.o.foldlevel = 99 --  NOTE: ufo provider needs a large value, value can be tuned
      vim.o.foldlevelstart = 99

      -- keymaps
      vim.keymap.set("n", "<leader>uf", "za", { desc = "[UFO] fold: toggle current fold" })
      vim.keymap.set("n", "<leader>uo", ufo.openAllFolds, { desc = "[UFO] fold: open all" })
      vim.keymap.set("n", "<leader>uc", ufo.closeAllFolds, { desc = "[UFO] fold: close all" })
      vim.keymap.set("n", "<leader>ur", ufo.openFoldsExceptKinds, { desc = "[UFO] fold: open one level" })
      vim.keymap.set("n", "<leader>um", ufo.closeFoldsWith, { desc = "[UFO] fold: close one level" })
      vim.keymap.set("n", "<leader>up", function()
        local winid = ufo.peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end, { desc = "[UFO] fold: peek folded lines (or hover)" })
    end,
  },
}
