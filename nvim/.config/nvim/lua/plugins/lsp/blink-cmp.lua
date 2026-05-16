return {
  "saghen/blink.cmp",
  version = "*",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "saghen/blink.lib",
    "rafamadriz/friendly-snippets",
  },

  build = "cargo build --release",

  opts = {
    keymap = {
      preset = "default", --  INFO: ctrl-n/ctrl-p to navigate
      ["<Tab>"] = { "select_and_accept", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<C-c>"] = { "cancel", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    },

    appearance = {
      nerd_font_variant = "mono",
      kind_icons = {
        Text = "󰉿",
        Method = "󰆧",
        Function = "󰊕",
        Constructor = "",
        Field = "󰜢",
        Variable = "󰀫",
        Class = "󰠱",
        Interface = "",
        Module = "",
        Property = "󰜢",
        Unit = "󰑭",
        Value = "󰎠",
        Enum = "",
        Keyword = "󰌋",
        Snippet = "",
        Color = "󰏘",
        File = "󰈙",
        Reference = "󰈇",
        Folder = "󰉋",
        EnumMember = "",
        Constant = "󰏿",
        Struct = "󰙅",
        Event = "",
        Operator = "󰆕",
        TypeParameter = "󰅲",
      },
    },

    completion = {
      menu = {
        auto_show = true,
        border = "rounded",
        draw = {
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind_icon", "kind" },
          },
        },
      },

      documentation = {
        auto_show = false, --  INFO: only show when manually triggered via C-Space
        auto_show_delay_ms = 0,
        window = {
          border = "rounded",
        },
      },

      ghost_text = {
        enabled = true,
      },

      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },
    },

    sources = {
      default = { "lsp", "snippets", "dadbod", "path", "buffer" },
      providers = {
        lsp = {
          score_offset = 90,
        },
        snippets = {
          score_offset = 80,
          min_keyword_length = 2,
        },
        dadbod = {
          name = "Dadbod",
          module = "vim_dadbod_completion.blink",
          score_offset = 75,
        },
        path = {
          score_offset = 70,
        },
        buffer = {
          score_offset = 50,
          min_keyword_length = 3, -- don't suggest single char buffer words
        },
      },
    },

    snippets = {
      preset = "default", -- uses built-in snippet engine + friendly-snippets
    },

    fuzzy = {
      implementation = "rust",
      sorts = { "score", "sort_text" },
    },

    cmdline = {
      enabled = true,
      keymap = {
        preset = "cmdline",
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
      },
      completion = {
        menu = { auto_show = true },
        list = {
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },
      },
    },
  },
}
