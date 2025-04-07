return {
  "stevearc/conform.nvim",
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "n",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      eruby = { "erb_lint" },
      php = { "php_cs_fixer" },
      javascript = { "eslint_d", "prettierd" },
      html = { "prettierd" }
    },
    formatters = {
      erb_lint = {
        stdin = false,
        tmpfile_format = ".conform.$RANDOM.$FILENAME",
        command = "bundle",
        args = { "exec", "erb_lint", "--autocorrect", "$FILENAME" },
      },
    },
  },
}
