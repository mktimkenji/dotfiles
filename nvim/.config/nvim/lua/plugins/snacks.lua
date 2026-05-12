return {
  "folke/snacks.nvim",
  lazy = false,
  ---@diagnostic disable: unused-local, undefined-global
  opts = {
    notifier = {},
    input = {},
    indent = {},

    zen = {
      toggles = {
        dim = true, -- dim inactive portions
        git_signs = false, -- hide gitsigns
        mini_diff_signs = false,
        diagnostics = false, -- hide lsp diagnostics
        inlay_hints = false,
      },
      show = {
        statusline = false,
        tabline = false,
      },
      win = {
        backdrop = { transparent = true, blend = 40 },
        width = 120, -- writing width, adjust to taste
      },
      on_open = function(_win)
        vim.opt.linebreak = true -- wrap at word boundaries
        vim.opt.list = false -- hide listchars (indent guides etc)
      end,
      on_close = function(_win)
        vim.opt.linebreak = false
        vim.opt.list = true
      end,
      vim.keymap.set("n", "<leader>z", function()
        Snacks.zen()
      end, { desc = "Zen mode" }),
    },

    zoom = {
      toggles = {},
      show = { statusline = true, tabline = true },
      win = {
        backdrop = false,
        width = 0,
      },
      vim.keymap.set("n", "<leader>sm", function()
        Snacks.zen.zoom()
      end, { desc = "Zoom window toggle" }),
    },

    dashboard = {
      enabled = true,
      width = 60,
      row = nil,
      col = nil,
      pane_gap = 4,
      autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",

      preset = {
        pick = nil,
        keys = {
          { icon = " ", key = "n", desc = "New File", action = "<cmd>ene <BAR> startinsert<CR>" },
          { icon = " ", key = "r", desc = "Recent Files", action = "<cmd>Telescope oldfiles<CR>" },
          { icon = " ", key = "p", desc = "Recent Projects", action = "<cmd>Telescope session-lens<CR>" },
          { icon = " ", key = "f", desc = "Find File", action = "<cmd>Telescope find_files<CR>" },
          { icon = " ", key = "s", desc = "Find String", action = "<cmd>Telescope live_grep<CR>" },
          { icon = " ", key = "w", desc = "Restore session", action = "<cmd>AutoSession restore<CR>" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = "<cmd>Lazy<CR>", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "m", desc = "Mason", action = "<cmd>Mason<CR>" },
          { icon = " ", key = "q", desc = "Quit", action = "<cmd>qa<CR>" },
        },

        header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
      },

      formats = {
        icon = function(item)
          if item.file and item.icon == "file" or item.icon == "directory" then
            return Snacks.dashboard.icon(item.file, item.icon)
          end
          return { item.icon, width = 2, hl = "icon" }
        end,
        footer = { "%s", align = "center" },
        header = { "%s", align = "center" },
        file = function(item, ctx)
          local fname = vim.fn.fnamemodify(item.file, ":~")
          fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
          if #fname > ctx.width then
            local dir = vim.fn.fnamemodify(fname, ":h")
            local file = vim.fn.fnamemodify(fname, ":t")
            if dir and file then
              file = file:sub(-(ctx.width - #dir - 2))
              fname = dir .. "/…" .. file
            end
          end
          local dir, file = fname:match("^(.*)/(.+)$")
          return dir and { { dir .. "/", hl = "dir" }, { file, hl = "file" } } or { { fname, hl = "file" } }
        end,
      },

      sections = {
        { section = "header" },
        {
          pane = 2,
          section = "terminal",
          cmd = "chafa --font-ratio 2/5 --symbols all --size 60x15 "
            .. vim.fn.stdpath("config")
            .. "/assets/heihachi.jpg",
          width = 60,
          height = 15,
          padding = { 1, 2 },
        },
        { section = "keys", gap = 1, padding = 1 },
        { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        {
          pane = 2,
          icon = " ",
          title = "Git Status",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = "git status --short --branch --renames",
          height = 5,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
        },
        { section = "startup" },
        {
          align = "center",
          padding = 1,
          text = (function()
            local v = vim.version()
            local version = string.format("v%d.%d.%d", v.major, v.minor, v.patch)
            local date = os.date("%a %d %b %Y")
            return {
              { "  " .. version, hl = "footer" },
              { "   󰃭 " .. date, hl = "footer" },
            }
          end)(),
        },
      },
    },
  },
}
