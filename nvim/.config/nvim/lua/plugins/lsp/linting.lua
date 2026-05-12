return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      -- Web
      javascript = { "biomejs" },
      typescript = { "biomejs" },
      javascriptreact = { "biomejs" },
      typescriptreact = { "biomejs" },
      -- css & json handled through lsp

      -- Scripting
      bash = { "shellcheck" },
      sh = { "shellcheck" },
      python = { "ruff" },
      -- lua "selene" for linting not enabled, handled by lua_ls

      -- Markup / Config
      markdown = { "markdownlint-cli2" },
      yaml = { "yamllint" },
      -- html & xml handled through lsp

      dockerfile = { "hadolint" },

      sql = { "sqlfluff" },

      -- JVM
      kotlin = { "ktlint" },
      groovy = { "npm-groovy-lint" },
      -- java excluded

      -- C/C++  INFO: packaged with clangd
      c = { "clangtidy" },
      cpp = { "clangtidy" },
    }

    -- auto-lint on these events
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      callback = function()
        lint.try_lint()
      end,
    })

    -- manual lint keymap
    vim.keymap.set("n", "<leader>ml", function()
      lint.try_lint()
    end, { desc = "Make lint (trigger linting)" })
  end,
}
