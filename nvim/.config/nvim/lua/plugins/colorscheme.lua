return {
  "folke/tokyonight.nvim",
  priority = 1000,
  config = function()
    local current_variant = "night"
    local transparent = false

    local function apply(variant, is_transparent)
      require("tokyonight").setup({
        transparent = is_transparent,
        styles = {
          sidebars = is_transparent and "transparent" or "dark",
          floats = is_transparent and "transparent" or "dark",
        },
      })
      vim.cmd("colorscheme tokyonight-" .. variant)
    end

    local function set_theme(variant)
      current_variant = variant
      apply(variant, transparent)
    end

    -- default
    apply(current_variant, transparent)

    -- variant keymaps
    vim.keymap.set("n", "<leader>bn", function()
      set_theme("night")
    end, { desc = "Theme: Night" })
    vim.keymap.set("n", "<leader>bs", function()
      set_theme("storm")
    end, { desc = "Theme: Storm" })
    vim.keymap.set("n", "<leader>bm", function()
      set_theme("moon")
    end, { desc = "Theme: Moon" })
    vim.keymap.set("n", "<leader>bd", function()
      set_theme("day")
    end, { desc = "Theme: Day" })

    -- transparency toggle
    vim.keymap.set("n", "<leader>bg", function()
      transparent = not transparent
      apply(current_variant, transparent)
      vim.notify("Transparency: " .. (transparent and "ON" or "OFF"))
    end, { desc = "Toggle transparency" })
  end,
}
