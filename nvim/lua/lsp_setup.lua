local nvim_lsp = require'nvim_lsp'
require'treesitter_setup'
require'lsp_overrides'

nvim_lsp.tsserver.setup{}
nvim_lsp.vimls.setup{}
nvim_lsp.intelephense.setup{}
nvim_lsp.gopls.setup{}
nvim_lsp.pyls.setup{}
nvim_lsp.sumneko_lua.setup{
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = {'vim'}
      },
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("~/build/neovim/src/nvim/lua")] = true,
        }
      },
    }
  }
}

function _G.omnifunc_sync(findstart, base)
  local bufnr = vim.api.nvim_get_current_buf()
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local line_to_cursor = line:sub(1, pos[2])
  local textMatch = vim.fn.match(line_to_cursor, '\\k*$')

  if findstart == 1 then
    return textMatch
  end

  local params = vim.lsp.util.make_position_params()

  local result = vim.lsp.buf_request_sync(bufnr, 'textDocument/completion', params, 2000)
  local items = {}
  if result then
    for _, item in ipairs(result) do
      if not item.err then
        local matches = vim.lsp.util.text_document_completion_list_to_complete_items(item.result, base)
        vim.list_extend(items, matches)
      end
    end
  end

  if vim.tbl_isempty(items) then
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-g><C-g><C-n>', true, false, true))
    return -3
  end

  return items
end
