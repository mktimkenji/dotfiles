return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "nvim-telescope/telescope-media-files.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")

    ---@diagnostic disable: undefined-field
    telescope.setup({
      defaults = {
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
        file_ignore_patterns = {
          ".git/",
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
        media_files = {
          filetypes = { "png", "webp", "jpg", "jpeg", "gif", "pdf" },
          find_cmd = "fd",
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          find_command = {
            "fd",
            "--type",
            "f",
            "--hidden",
            "--follow",
            "--exclude",
            ".git",
          },
        },
        live_grep = {
          additional_args = function()
            return { "--hidden", "--follow" }
          end,
        },
      },
    })
    telescope.load_extension("fzf")
    telescope.load_extension("media_files")

    local keymap = vim.keymap

    -- Files
    keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Fuzzy find files in cwd" })
    keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Fuzzy find recent files" })
    keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Find string in cwd" })
    keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find word under cursor in cwd" })
    keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find open buffers" })
    keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find keymaps" })
    keymap.set("n", "<leader>fm", ":Telescope media_files<CR>", { desc = "Find media files" }) --  INFO: find media files doesn't work for hidden directories

    -- Git
    keymap.set("n", "<leader>fgc", builtin.git_commits, { desc = "Find git commits" })
    keymap.set("n", "<leader>fgb", builtin.git_branches, { desc = "Find git branches" })

    -- LSP (override lsp.lua mappings with telescope UI)
    keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, { desc = "LSP: document symbols" })
    keymap.set("n", "<leader>dw", builtin.lsp_workspace_symbols, { desc = "LSP: workspace symbols" })
    keymap.set("n", "gr", builtin.lsp_references, { desc = "LSP: go to references" })
    keymap.set("n", "gd", builtin.lsp_definitions, { desc = "LSP: go to definition" })
    keymap.set("n", "gi", builtin.lsp_implementations, { desc = "LSP: go to implementation" })
  end,
}
