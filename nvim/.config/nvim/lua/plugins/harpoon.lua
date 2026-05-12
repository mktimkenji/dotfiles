return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    -- telescope integration
    local conf = require("telescope.config").values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end
      require("telescope.pickers")
        .new({}, {
          prompt_title = "Harpoon",
          finder = require("telescope.finders").new_table({
            results = file_paths,
          }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        })
        :find()
    end

    -- list management
    vim.keymap.set("n", "<leader>ha", function()
      harpoon:list():add()
    end, { desc = "Harpoon: add file" })
    vim.keymap.set("n", "<leader>hl", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Harpoon: toggle quick menu" })
    vim.keymap.set("n", "<leader>hf", function()
      toggle_telescope(harpoon:list())
    end, { desc = "Harpoon: open in Telescope" })

    -- slot navigation
    vim.keymap.set("n", "<leader>hi", function()
      harpoon:list():select(1)
    end, { desc = "Harpoon: go to slot 1" })
    vim.keymap.set("n", "<leader>hk", function()
      harpoon:list():select(2)
    end, { desc = "Harpoon: go to slot 2" })
    vim.keymap.set("n", "<leader>hl", function()
      harpoon:list():select(3)
    end, { desc = "Harpoon: go to slot 3" })
    vim.keymap.set("n", "<leader>hs", function()
      harpoon:list():select(4)
    end, { desc = "Harpoon: go to slot 4" })

    -- prev/next cycling
    vim.keymap.set("n", "<leader>he", function()
      harpoon:list():prev()
    end, { desc = "Harpoon: prev buffer" })
    vim.keymap.set("n", "<leader>hh", function()
      harpoon:list():next()
    end, { desc = "Harpoon: next buffer" })
  end,
}
