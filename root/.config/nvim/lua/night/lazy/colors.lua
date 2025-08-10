return {
  {
    "folke/tokyonight.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("tokyonight").setup({
        style = "storm",
        terminal_colors = true,
        transparent = true,
        styles = {
          -- Style to be applied to different syntax groups
          -- Value is any valid attr-list value for `:help nvim_set_hl`
          comments = { italic = false },
          keywords = { italic = false },
          -- Background styles. Can be "dark", "transparent" or "normal"
          sidebars = "dark", -- style for sidebars, see below
          floats = "dark", -- style for floating windows
        },
      })

      -- load the colorscheme here
      vim.cmd([[ colorscheme tokyonight ]])
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        disable_background = true,
        disable_float_background = true,
        disable_italics = true,
        variant = "dark",
        dark_variant = "main",
      })
      vim.cmd("colorscheme rose-pine")
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

      local colors = require("rose-pine.palette");

      -- Some coloring for elixir
      vim.api.nvim_set_hl(0, "@string.special.symbol.elixir", { fg = colors.foam })
      vim.api.nvim_set_hl(0, "@module.elixir", { fg = colors.iris, bold = true })
    end,
  },
}
