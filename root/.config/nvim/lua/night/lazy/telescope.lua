return {
  "nvim-telescope/telescope.nvim",

  tag = "0.1.5",

  dependencies = {
    "nvim-lua/plenary.nvim",
    "BurntSushi/ripgrep",
    "rrothenberger/telescope-harpoon2.nvim",
  },

  config = function()
    local actions = require("telescope.actions")
    require("telescope").setup({
      defaults = {
        mappings = {
          i = {
            ["<esc>"] = actions.close,
          },
        },
      },
      file_ignore_patterns = { "node_modules" },
    })

    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
    vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
    vim.keymap.set("n", "<C-p>", builtin.git_files, {})

    require("telescope").load_extension("harpoon2")
    local harpoon_extension = require("telescope").extensions.harpoon2
    vim.keymap.set("n", "<C-e>", function()
      harpoon_extension.ui:new({
        prompt_title = "Harpoon",
      })
    end)
  end,
}
