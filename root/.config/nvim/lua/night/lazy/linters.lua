return {
  "mfussenegger/nvim-lint",
  event = {
    "BufReadPre",
    "BufNewFile",
  },
  config = function()
    local lint = require("lint")

    lint.linters.erb_lint = {
      cmd = "bundle",
      args = {
        "exec",
        "erblint",
        "--format",
        "json",
        "--stdin",
        function()
          return vim.api.nvim_buf_get_name(0)
        end,
      },
      stdin = true,
      stream = "stdout",
      ignore_exitcode = true,
      parser = function(output)
        local diagnostics = {}
        local decoded = vim.json.decode(output)

        if not decoded.files[1] then
          return diagnostics
        end

        local offences = decoded.files[1].offenses

        for _, off in pairs(offences) do
          table.insert(diagnostics, {
            source = "erb_lint",
            lnum = off.location.start_line - 1,
            col = off.location.start_column,
            end_lnum = off.location.last_line - 1,
            end_col = off.location.last_column,
            severity = vim.diagnostic.severity.WARN,
            message = off.message,
            code = off.linter,
          })
        end

        return diagnostics
      end,
    }

    lint.linters_by_ft = {
      eruby = { "erb_lint" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
