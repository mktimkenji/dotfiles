return {
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "bashls",
        "clangd",
        "cssls",
        "dockerls",
        "html",
        "jdtls",
        "jsonls",
        "kotlin_language_server",
        "lemminx",
        "lua_ls",
        "marksman",
        "powershell_es",
        "pyright",
        "rust_analyzer",
        "sqlls",
        "taplo",
        "ts_ls",
        "yamlls",
      },
      automatic_enable = {
        exclude = { "jdtls" }, -- nvim-jdtls
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        -- debugger
        "java-debug-adapter",
        "java-test",
        "debugpy",
        "codelldb",
        "js-debug-adapter",
        "bash-debug-adapter",
        -- formatters
        "biome",
        "prettier",
        "stylua",
        "shfmt",
        "clang-format",
        "ktlint",
        "ruff",
        "sql-formatter",
        "npm-groovy-lint",
        -- linters
        "shellcheck",
        "markdownlint-cli2",
        "hadolint",
        "sqlfluff",
        "yamllint",
      },
      auto_update = false, -- don't auto-update on every startup
      run_on_start = true, -- install missing tools on startup
    },
  },
}
