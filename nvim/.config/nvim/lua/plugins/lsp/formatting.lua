return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        -- Web
        javascript = { "biome-check" },
        typescript = { "biome-check" },
        javascriptreact = { "biome-check" },
        typescriptreact = { "biome-check" },
        json = { "biome-check" },
        jsonc = { "biome-check" },
        css = { "biome-check" },

        -- Markup / Config
        html = { "prettier" },
        xml = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        toml = { "taplo" },

        -- Systems
        c = { "clang-format" },
        cpp = { "clang-format" },

        -- Rust  NOTE: installed with rustup default stable
        rust = { "rustfmt" },

        -- JVM
        kotlin = { "ktlint" },
        groovy = { "npm-groovy-lint" },
        -- java excluded, handled by nvim-jdtls

        -- Scripting
        python = { "ruff_format" },
        lua = { "stylua" },
        bash = { "shfmt" },
        sh = { "shfmt" },

        -- Data / query
        sql = { "sql_formatter" },
      },

      -- INFO: autoformats on save
      -- format_on_save = {
      --   lsp_fallback = true,
      --   async = false,
      --   timeout_ms = 1000,
      -- },
    })

    -- individual formatter config
    conform.formatters.prettier = {
      args = {
        "--stdin-filepath",
        "$FILENAME",
        "--tab-width",
        "2",
        "--use-tabs",
        "false",
        "--prose-wrap",
        "always",
      },
    }

    conform.formatters.shfmt = {
      prepend_args = { "-i", "2" },
    }

    conform.formatters.stylua = {
      prepend_args = {
        "--indent-type",
        "Spaces",
        "--indent-width",
        "2",
      },
    }

    conform.formatters["clang-format"] = {
      prepend_args = {
        "--style={BasedOnStyle: Google, IndentWidth: 4}",
      },
    }

    -- formatter keymap
    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1500,
      })
    end, { desc = "Make pretty (format file)" })
  end,
}
