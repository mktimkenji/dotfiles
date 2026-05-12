vim.g.mapleader = " "
vim.g.localleader = " "

local keymap = vim.keymap

keymap.set("n", "<leader>ch", ":checkhealth<CR>", { desc = "Check health" })
keymap.set("n", "<leader><ESC>", ":Ex<CR>", { desc = "Explorer" })
keymap.set("n", "<leader>so", ":so<CR>", { desc = "Source" })
keymap.set("n", "<leader>sf", ":w<CR>", { desc = "Save file" })
keymap.set("n", "<leader>q<CR>", ":q<CR>", { desc = "Quit buffer" })
keymap.set("n", "<leader>qa", ":qa<CR>", { desc = "Quit application" })

keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- jumps
keymap.set("n", "gb", "<C-o>", { desc = "Go backward" })
keymap.set("n", "gj", "<C-i>", { desc = "Go forward" })

-- resize with arrows
keymap.set("n", "<Up>", ":resize +2<CR>", { desc = "Increase current portrait window size" })
keymap.set("n", "<Down>", ":resize -2<CR>", { desc = "Decrease current portrait window size" })
keymap.set("n", "<Right>", ":vertical resize +2<CR>", { desc = "Increase current horizontal window size" })
keymap.set("n", "<Left>", ":vertical resize -2<CR>", { desc = "Decrease current horizontal window size" })

-- split window
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- tabs
keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tl", "<cmd>tabn<CR>", { desc = "Next tab to the right" })
keymap.set("n", "<leader>tj", "<cmd>tabp<CR>", { desc = "Previous tab to the left" })
keymap.set("n", "<leader>to", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection downwards" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection upwards" })

-- original buffer after pasting and deleting
keymap.set("v", "<leader>p", '"_dP', { desc = "Keep original buffer after pasting in visual mode" })
keymap.set("x", "<leader>p", '"_dP', { desc = "Keep original buffer after pasting in select mode" })
keymap.set("n", "x", '"_x', { desc = "Keep original buffer after deleting character" })
keymap.set("n", "<leader>dap", '"_dap', { desc = "Keep original buffer after deleting around paragraph" })
keymap.set("n", "<leader>dip", '"_dip', { desc = "Keep original buffer after deleting inside paragraph" })

keymap.set("n", "J", "mzJ`z", { desc = "Keep cursor in place after appending lines" })

keymap.set("n", "<leader>lw", "<cmd>set wrap!<CR>", { desc = "Toggle line wrapping" })

keymap.set("n", "<leader>y", ":%y<CR>", { desc = "Copy whole file" })
keymap.set("n", "<leader>df", 'gg"_dG', { desc = "Delete whole file" })
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights on search" })

-- keep cursor in the middle of the screen
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

keymap.set("n", "<leader>i", function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.cmd("normal! gg=G")
  vim.api.nvim_win_set_cursor(0, cursor)
end, { desc = "Indent whole file" })

-- plugin managers
keymap.set("n", "<leader>lz", ":Lazy<CR>", { desc = "Toggle Lazy window" })
keymap.set("n", "<leader>ms", ":Mason<CR>", { desc = "Toggle Mason window" })
