return {
  { "rcasia/neotest-java", ft = "java" },
  { "marilari88/neotest-vitest", ft = { "typescript", "javascript", "typescriptreact", "javascriptreact" } },
  { "haydenmeade/neotest-jest", ft = { "typescript", "javascript", "typescriptreact", "javascriptreact" } },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- adapters
      "rcasia/neotest-java",
      "marilari88/neotest-vitest",
      "haydenmeade/neotest-jest",
    },
    event = { "BufReadPost" },
    config = function()
      require("neotest").setup({
        adapters = {
          -- Java — JUnit 4, JUnit 5, and TestNG (via JUnit Platform)
          require("neotest-java")({
            incremental_build = true,
          }),

          -- auto-detects vitest.config.ts / vite.config.ts in project root
          require("neotest-vitest")({
            -- filter_dir — skip node_modules and dist automatically
            filter_dir = function(name, _, _)
              return name ~= "node_modules" and name ~= "dist" and name ~= "build"
            end,
          }),

          -- Jest — fallback for older JS/TS projects not using Vite
          require("neotest-jest")({
            jestCommand = "npx jest",
            jestConfigFile = "jest.config.js", --  NOTE: or jest.config.ts
            env = { CI = "true" },
            cwd = function()
              return vim.fn.getcwd()
            end,
          }),
        },

        -- UI
        icons = {
          -- test status icons shown in gutter and summary
          passed = "✓",
          failed = "✗",
          running = "󰑮",
          skipped = "○",
          unknown = "?",
          watching = "󰈈",
          -- tree structure icons in summary panel
          expanded = "",
          collapsed = "",
          child_indent = "│",
          child_prefix = "├",
          final_child_prefix = "└",
          final_child_indent = " ",
          non_collapsible = "─",
        },

        -- summary opens as a vertical split on the right
        summary = {
          open = "botright vsplit | vertical resize 45",
          animated = true, -- animate running indicator
          follow = true, -- auto-scroll to running test
          expand_errors = true, -- auto-expand failed tests
          mappings = {
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "e",
            output = "o",
            short = "O",
            attach = "a",
            enter = "i",
            jump = "<C-CR>",
            stop = "u",
            run = "r",
            debug = "d",
            mark = "m",
            run_marked = "R",
            debug_marked = "D",
            clear_marked = "M",
            target = "t",
            clear_target = "T",
            next_failed = "]f",
            prev_failed = "[f",
          },
        },

        -- output panel
        output = {
          open_on_run = "short", --  INFO: "short" shows only failed, "true" always opens
          enter = false,
        },

        output_panel = {
          enabled = true,
          open = "botright split | resize 15",
        },

        diagnostic = {
          enabled = true,
          severity = vim.diagnostic.severity.ERROR,
        },

        signs = {
          enabled = true,
          priority = 10,
        },

        status = {
          enabled = true,
          virtual_text = true,
          signs = true,
        },

        -- populate quickfix list with failures for easy navigation
        quickfix = {
          enabled = true,
          open = false, -- don't auto-open quickfix, use summary instead
        },

        run = {
          enabled = true,
        },

        discovery = {
          enabled = true,
          concurrent = 1,
          filter_dir = function(name, _, _)
            -- skip heavy directories during test discovery
            return name ~= "node_modules" and name ~= ".git" and name ~= "dist" and name ~= "build" and name ~= "target"
          end,
        },

        watch = {
          enabled = true,
        },
      })

      -- keymaps
      local map = vim.keymap.set
      local nt = require("neotest")

      -- run
      map("n", "<leader>nr", function()
        nt.run.run()
      end, { desc = "Test: run nearest" })
      map("n", "<leader>nf", function()
        nt.run.run(vim.fn.expand("%"))
      end, { desc = "Test: run file" })
      map("n", "<leader>ns", function()
        nt.run.run(vim.fn.getcwd())
      end, { desc = "Test: run suite" })
      map("n", "<leader>nl", function()
        nt.run.run_last()
      end, { desc = "Test: run last" })
      map("n", "<leader>nn", function()
        nt.run.stop()
      end, { desc = "Test: stop" })

      -- watch mode (re-runs on file change)
      map("n", "<leader>nw", function()
        nt.watch.toggle(vim.fn.expand("%"))
      end, { desc = "Test: toggle watch file" })

      -- UI panels
      map("n", "<leader>nt", function()
        nt.summary.toggle()
      end, { desc = "Test: toggle summary panel" })
      map("n", "<leader>no", function()
        nt.output_panel.toggle()
      end, { desc = "Test: toggle output panel" })
      map("n", "<leader>np", function()
        nt.output.open({ enter = true })
      end, { desc = "Test: open output (floating)" })

      -- navigation
      map("n", "]n", function()
        nt.jump.next({ status = "failed" })
      end, { desc = "Test: jump to next failed" })
      map("n", "[n", function()
        nt.jump.prev({ status = "failed" })
      end, { desc = "Test: jump to prev failed" })
    end,
  },
}
