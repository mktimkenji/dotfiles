return {
  {
    "tpope/vim-dadbod",
    lazy = true,
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql", "plsql" },
    lazy = true,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          ---@diagnostic disable-next-line: undefined-field
          require("blink.cmp").add_source({
            name = "vim-dadbod",
            module = "vim_dadbod_completion.blink",
          })
        end,
      })
    end,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
      "kristijanhusak/vim-dadbod-completion",
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
      "DBUIRenameBuffer",
      "DBUILastQueryInfo",
    },
    keys = {
      { "<leader>db<CR>", "<cmd>DBUIToggle<CR>", desc = "DB: toggle UI" },
      { "<leader>dba", "<cmd>DBUIAddConnection<CR>", desc = "DB: add connection" },
      { "<leader>dbf", "<cmd>DBUIFindBuffer<CR>", desc = "DB: find buffer" },
    },
    init = function()
      -- UI appearance
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 35

      -- icons
      vim.g.db_ui_icons = {
        expanded = {
          db = "󰆼 ",
          buffers = "󰦄 ",
          saved_queries = " ",
          schemas = " ",
          schema = "󱁏 ",
          tables = "󰓫 ",
          table = "󰓫 ",
        },
        collapsed = {
          db = "󰆼 ",
          buffers = "󰦄 ",
          saved_queries = " ",
          schemas = " ",
          schema = "󱁏 ",
          tables = "󰓫 ",
          table = "󰓫 ",
        },
        saved_query = " ",
        new_query = "󱀶 ",
        tables = "󰓫 ",
        buffers = "󰦄 ",
        add_connection = "󰆺 ",
        connection_ok = "✓",
        connection_error = "✗",
      }

      -- behaviors
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/dadbod-queries"
      vim.g.db_ui_execute_on_save = 0 -- use manual keymap instead
      vim.g.db_ui_use_nvim_notify = 1 -- use nvim notifications for feedback
      vim.g.db_ui_default_query = "SELECT * FROM `{table}` LIMIT 200"

      -- quick helpers, appear as quick actions on each table in the UI sidebar
      vim.g.db_ui_table_helpers = {
        postgresql = {
          List = "SELECT * FROM {table} LIMIT 200",
          Count = "SELECT COUNT(*) FROM {table}",
          Structure = "\\d {table}",
          Indexes = "SELECT indexname, indexdef FROM pg_indexes WHERE tablename = '{table}'",
          ["FK refs"] = "SELECT conname, conrelid::regclass, confrelid::regclass FROM pg_constraint WHERE confrelid = '{table}'::regclass",
        },
        mysql = {
          List = "SELECT * FROM `{table}` LIMIT 200",
          Count = "SELECT COUNT(*) FROM `{table}`",
          Structure = "DESCRIBE `{table}`",
          Indexes = "SHOW INDEXES FROM `{table}`",
        },
        sqlite = {
          List = "SELECT * FROM {table} LIMIT 200",
          Count = "SELECT COUNT(*) FROM {table}",
          Structure = "PRAGMA table_info({table})",
          Indexes = "PRAGMA index_list({table})",
        },
        ["sql server"] = {
          List = "SELECT TOP 200 * FROM {table}",
          Count = "SELECT COUNT(*) FROM {table}",
          Structure = "sp_help {table}",
          Indexes = "sp_helpindex {table}",
        },
        oracle = {
          List = "SELECT * FROM {table} WHERE ROWNUM <= 200",
          Count = "SELECT COUNT(*) FROM {table}",
          Structure = "DESC {table}",
        },
      }
    end,

    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set({ "n", "v" }, keys, func, { buffer = event.buf, desc = "DB: " .. desc })
          end

          -- execute query under cursor or visual selection
          map("<leader>dbr", "<Plug>(DBUI_ExecuteQuery)", "Run query")
          -- save current query
          map("<leader>dbs", "<Plug>(DBUI_SaveQuery)", "Save query")
          -- edit bind parameters (for queries with :param placeholders)
          map("<leader>dbe", "<Plug>(DBUI_EditBindParameters)", "Edit parameters")
          -- toggle result layout (vertical/horizontal split)
          map("<leader>dbl", "<Plug>(DBUI_ToggleResultLayout)", "Toggle result layout")
        end,
      })
    end,
  },
}
