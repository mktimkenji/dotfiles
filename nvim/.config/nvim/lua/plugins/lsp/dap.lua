return {
  ---@diagnostic disable: undefined-field
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
    },
    keys = {
      {
        "<leader>vc",
        function()
          require("dap").continue()
        end,
        desc = "DAP: continue / start",
      },
      {
        "<leader>vq",
        function()
          require("dap").terminate()
        end,
        desc = "DAP: terminate session",
      },
      {
        "<leader>vb",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "DAP: toggle breakpoint",
      },
      {
        "<leader>vB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "DAP: conditional breakpoint",
      },
      {
        "<leader>vl",
        function()
          require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
        end,
        desc = "DAP: log point",
      },
      {
        "<leader>vo",
        function()
          require("dap").step_over()
        end,
        desc = "DAP: step over",
      },
      {
        "<leader>vi",
        function()
          require("dap").step_into()
        end,
        desc = "DAP: step into",
      },
      {
        "<leader>vO",
        function()
          require("dap").step_out()
        end,
        desc = "DAP: step out",
      },
      {
        "<leader>vr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "DAP: toggle REPL",
      },
      {
        "<leader>dL",
        function()
          require("dap").run_last()
        end,
        desc = "DAP: run last config",
      },
      {
        "<leader>vx",
        function()
          require("dap").clear_breakpoints()
        end,
        desc = "DAP: clear all breakpoints",
      },
      {
        "<leader>vp",
        function()
          require("dap").pause()
        end,
        desc = "DAP: pause",
      },
    },
    config = function()
      local dap = require("dap")

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define(
        "DapBreakpointCondition",
        { text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" }
      )
      vim.fn.sign_define(
        "DapBreakpointRejected",
        { text = "○", texthl = "DapBreakpointRejected", linehl = "", numhl = "" }
      )
      vim.fn.sign_define("DapLogPoint", { text = "◎", texthl = "DapLogPoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })

      -- Rust / C / C++ (codelldb)
      local codelldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"

      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = codelldb_path,
          args = { "--port", "${port}" },
        },
      }

      dap.configurations.rust = {
        {
          name = "Launch (debug build)",
          type = "codelldb",
          request = "launch",
          program = function()
            -- prompt to pick the binary to debug
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
      }

      -- C and C++ reuse codelldb
      dap.configurations.c = dap.configurations.rust
      dap.configurations.cpp = dap.configurations.rust

      -- TypeScript / JavaScript (js-debug-adapter)
      local js_debug_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

      dap.adapters["pwa-node"] = {
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
          command = "node",
          args = { js_debug_path, "${port}", "127.0.0.1" },
        },
      }

      for _, lang in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        dap.configurations[lang] = {
          {
            name = "Launch Node program",
            type = "pwa-node",
            request = "launch",
            program = "${file}",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
          {
            name = "Attach to Node process",
            type = "pwa-node",
            request = "attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
          },
        }
      end

      -- Bash
      local bash_debug_path = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir"

      dap.adapters.sh = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/bash-debug-adapter",
      }

      dap.configurations.sh = {
        {
          name = "Launch bash script",
          type = "sh",
          request = "launch",
          program = "${file}",
          cwd = "${workspaceFolder}",
          pathBashdb = bash_debug_path .. "/bashdb",
          pathBashdbLib = bash_debug_path,
          pathCat = "cat",
          pathMkfifo = "mkfifo",
          pathPkill = "pkill",
          env = {},
          args = {},
          showDebugOutput = true,
          trace = false,
        },
      }
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
    opts = {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = true,
      show_stop_reason = true,
      commented = false,
      only_first_definition = true,
      all_references = false,
      display_callback = function(variable, _, _, _, options)
        if options.virt_text_pos == "inline" then
          return " = " .. variable.value
        else
          return variable.name .. " = " .. variable.value
        end
      end,
      virt_text_pos = "eol",
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    keys = {
      {
        "<leader>vv",
        function()
          require("dapui").toggle()
        end,
        desc = "DAP: toggle UI",
      },
      {
        "<leader>ve",
        function()
          require("dapui").eval()
        end,
        desc = "DAP: evaluate expression",
        mode = { "n", "v" },
      },
      {
        "<leader>vE",
        function()
          require("dapui").eval(vim.fn.input("Expression: "))
        end,
        desc = "DAP: evaluate input expression",
      },
    },
    config = function()
      local dapui = require("dapui")

      dapui.setup({
        icons = {
          expanded = "",
          collapsed = "",
          current_frame = "▶",
        },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            -- left sidebar: scopes, breakpoints, stacks, watches
            elements = {
              { id = "scopes", size = 0.40 },
              { id = "breakpoints", size = 0.20 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.15 },
            },
            size = 40,
            position = "left",
          },
          {
            -- bottom panel: REPL and console output
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 12,
            position = "bottom",
          },
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "",
            terminate = "",
            disconnect = "",
          },
        },
        floating = {
          max_height = 0.9,
          max_width = 0.9,
          border = "rounded",
          mappings = { close = { "q", "<Esc>" } },
        },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
        },
      })

      -- auto-open/close UI with DAP session
      local dap = require("dap")
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      -- uses the debugpy installed by mason
      local debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(debugpy_path)
    end,
  },
}
