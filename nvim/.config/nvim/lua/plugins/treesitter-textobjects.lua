return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local select = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")
    local swap = require("nvim-treesitter-textobjects.swap")

    local function sel(query, mode)
      return function()
        select.select_textobject(query, "textobjects", mode)
      end
    end

    -- functions
    vim.keymap.set({ "x", "o" }, "af", sel("@function.outer", "V"), { desc = "Select around function" })
    vim.keymap.set({ "x", "o" }, "if", sel("@function.inner", "v"), { desc = "Select inside function" })
    -- classes
    vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer", "V"), { desc = "Select around class" })
    vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner", "v"), { desc = "Select inside class" })
    -- parameters / arguments
    vim.keymap.set({ "x", "o" }, "aa", sel("@parameter.outer", "v"), { desc = "Select around parameter" })
    vim.keymap.set({ "x", "o" }, "ia", sel("@parameter.inner", "v"), { desc = "Select inside parameter" })
    -- conditionals
    vim.keymap.set({ "x", "o" }, "ai", sel("@conditional.outer", "V"), { desc = "Select around conditional" })
    vim.keymap.set({ "x", "o" }, "ii", sel("@conditional.inner", "v"), { desc = "Select inside conditional" })
    -- loops
    vim.keymap.set({ "x", "o" }, "al", sel("@loop.outer", "V"), { desc = "Select around loop" })
    vim.keymap.set({ "x", "o" }, "il", sel("@loop.inner", "v"), { desc = "Select inside loop" })
    -- blocks
    vim.keymap.set({ "x", "o" }, "ab", sel("@block.outer", "V"), { desc = "Select around block" })
    vim.keymap.set({ "x", "o" }, "ib", sel("@block.inner", "v"), { desc = "Select inside block" })

    local function mv(method, query)
      return function()
        move[method](query, "textobjects")
      end
    end

    -- next start
    vim.keymap.set({ "n", "x", "o" }, "]f", mv("goto_next_start", "@function.outer"), { desc = "Next function start" })
    vim.keymap.set({ "n", "x", "o" }, "]c", mv("goto_next_start", "@class.outer"), { desc = "Next class start" })
    vim.keymap.set({ "n", "x", "o" }, "]a", mv("goto_next_start", "@parameter.inner"), { desc = "Next parameter start" })
    vim.keymap.set({ "n", "x", "o" }, "]i", mv("goto_next_start", "@conditional.outer"), { desc = "Next conditional start" })
    vim.keymap.set({ "n", "x", "o" }, "]l", mv("goto_next_start", "@loop.outer"), { desc = "Next loop start" })
    -- next end
    vim.keymap.set({ "n", "x", "o" }, "]F", mv("goto_next_end", "@function.outer"), { desc = "Next function end" })
    vim.keymap.set({ "n", "x", "o" }, "]C", mv("goto_next_end", "@class.outer"), { desc = "Next class end" })
    -- prev start
    vim.keymap.set({ "n", "x", "o" }, "[f", mv("goto_previous_start", "@function.outer"), { desc = "Prev function start" })
    vim.keymap.set({ "n", "x", "o" }, "[c", mv("goto_previous_start", "@class.outer"), { desc = "Prev class start" })
    vim.keymap.set({ "n", "x", "o" }, "[a", mv("goto_previous_start", "@parameter.inner"), { desc = "Prev parameter start" })
    vim.keymap.set({ "n", "x", "o" }, "[i", mv("goto_previous_start", "@conditional.outer"), { desc = "Prev conditional start" })
    vim.keymap.set({ "n", "x", "o" }, "[l", mv("goto_previous_start", "@loop.outer"), { desc = "Prev loop start" })
    -- prev end
    vim.keymap.set({ "n", "x", "o" }, "[F", mv("goto_previous_end", "@function.outer"), { desc = "Prev function end" })
    vim.keymap.set({ "n", "x", "o" }, "[C", mv("goto_previous_end", "@class.outer"), { desc = "Prev class end" })

    --  INFO: swap with leader + r
    vim.keymap.set("n", "<leader>rn", function()swap.swap_next("@parameter.inner", "textobjects")end, { desc = "Swap parameter with next" })
    vim.keymap.set("n", "<leader>rf", function()swap.swap_next("@function.outer", "textobjects")end, { desc = "Swap function with next" })
    vim.keymap.set("n", "<leader>rp", function()swap.swap_previous("@parameter.inner", "textobjects")end, { desc = "Swap parameter with prev" })
    vim.keymap.set("n", "<leader>rF", function()swap.swap_previous("@function.outer", "textobjects")end, { desc = "Swap function with prev" })

    --  INFO: repeatbable moves with ; and ,
    local rep = require("nvim-treesitter-textobjects.repeatable_move")
    vim.keymap.set({ "n", "x", "o" }, ";", rep.repeat_last_move, { desc = "Repeat last move" })
    vim.keymap.set({ "n", "x", "o" }, ",", rep.repeat_last_move_opposite, { desc = "Repeat last move (reverse)" })
    vim.keymap.set({ "n", "x", "o" }, "f", rep.builtin_f_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "F", rep.builtin_F_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "t", rep.builtin_t_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "T", rep.builtin_T_expr, { expr = true })
  end,
}
