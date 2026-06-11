return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "b0o/schemastore.nvim",
  },
  config = function()
    vim.diagnostic.config({
      virtual_text = { prefix = "●", source = "if_many" },
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { border = "rounded", source = true },
    })

    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        -- INFO: overriden with telescope implementation
        -- map("gd", vim.lsp.buf.definition, "Go to definition")
        -- map("gi", vim.lsp.buf.implementation, "Go to implementation")
        -- map("gr", vim.lsp.buf.references, "Go to references")
        -- map("<leader>ds", vim.lsp.buf.document_symbol, "Document symbols")
        -- map("<leader>dw", vim.lsp.buf.workspace_symbol, "Workspace symbols")

        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("gt", vim.lsp.buf.type_definition, "Go to type definition")
        map("K", vim.lsp.buf.hover, "Hover docs")
        map("<leader><CR>", vim.lsp.buf.code_action, "Code action")
        map("<leader>dl", vim.diagnostic.open_float, "Show line diagnostic")
      end,
    })

    local capabilities = require("blink.cmp").get_lsp_capabilities()

    vim.lsp.config("*", {
      capabilities = capabilities,
    })

    vim.lsp.config("bashls", {
      filetypes = { "sh", "bash" },
    })

    vim.lsp.config("clangd", {
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-detail",
      },
      filetypes = { "c", "cpp", "objc", "objcpp" },
    })

    vim.lsp.config("cssls", {
      settings = {
        css = { validate = true, lint = { unknownAtRules = "ignore" } },
        scss = { validate = true },
        less = { validate = true },
      },
    })

    vim.lsp.config("html", {
      provideFormatter = false, -- conform.nvim
    })

    vim.lsp.config("jsonls", {
      settings = {
        json = {
          schemas = require("schemastore").json.schemas(),
          validate = { enable = true },
        },
      },
    })

    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
          hint = { enable = true },
        },
      },
    })

    vim.lsp.config("powershell_es", {
      bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
      filetypes = { "ps1", "psm1", "psd1" },
      settings = {
        powershell = {
          codeFormatting = {
            Preset = "OTBS",
          },
        },
      },
    })

    vim.lsp.config("pyright", {
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "basic",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            autoImportCompletions = true,
          },
        },
      },
    })

    vim.lsp.config("rust_analyzer", {
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = { command = "clippy" }, --  NOTE: linting, installed with rustup default stable
          cargo = { allFeatures = true },
          procMacro = { enable = true },
          inlayHints = {
            bindingModeHints = { enable = true },
            chainingHints = { enable = true },
            parameterHints = { enable = true },
            typeHints = { enable = true },
          },
        },
      },
    })

    vim.lsp.config("ts_ls", {
      filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
      },
      settings = {
        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayFunctionReturnTypeHints = true,
            includeInlayVariableTypeHints = true,
          },
        },
        javascript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayFunctionReturnTypeHints = true,
          },
        },
      },
    })

    vim.lsp.config("yamlls", {
      settings = {
        yaml = {
          schemaStore = {
            enable = false, -- disable built-in
            url = "",
          },
          schemas = require("schemastore").yaml.schemas(), -- auto schemas for k8s, compose, gh actions etc
          validate = true,
          completion = true,
          hover = true,
        },
      },
    })
  end,
}
