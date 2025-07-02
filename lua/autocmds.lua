-- Ensure the global flag is defined (important!)
if _G.colemak_keymaps_enabled == nil then
  _G.colemak_keymaps_enabled = false
  print 'WARN: _G.colemak_keymaps_enabled was not defined, setting to false.'
end

local miniFilesColemakGroup = vim.api.nvim_create_augroup('MiniFilesConditionalMaps', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = miniFilesColemakGroup,
  pattern = 'minifiles',
  desc = 'Setup conditional Colemak keymaps for mini.files respecting user config',
  callback = function(args)
    -- Ensure mini.files module is loaded to access its functions safely
    local mf = require 'mini.files'
    if not mf then
      vim.notify('mini.files module not found for autocmd', vim.log.levels.ERROR)
      return
    end

    local buf = args.buf
    -- Buffer-local options are key!
    local opts = { buffer = buf, noremap = true, silent = true }

    -- Define functions for the standard mini.files actions
    local function mf_go_in()
      mf.go_in()
    end
    local function mf_go_out()
      mf.go_out()
    end

    -- IMPORTANT: Your setup() mappings for 'I', 'M' are still active.
    -- This autocmd sets buffer-local maps for h,j,k,l, i,u, m
    -- which take precedence over global/setup maps for *these specific keys*
    -- in this buffer.

    -- === Conditional Mappings based on _G.colemak_keymaps_enabled ===

    -- --- Navigation and Mark Set (h, j, k, l) ---

    -- Physical 'h' key
    vim.keymap.set('n', 'i', function()
      if _G.colemak_keymaps_enabled then
        mf_go_in()
      end
    end, opts)

    -- Physical 'j' key (Assuming j is still Down)
    vim.keymap.set('n', 'm', function()
      mf_go_out()
    end, opts)
  end, -- end callback
}) -- end autocmd

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = '*.tmpl',
  callback = function()
    vim.bo.filetype = 'gotmpl'
  end,
  desc = 'Set filetype for Go HTML templates',
})

vim.api.nvim_create_autocmd({ 'BufWritePre' }, { pattern = { '*.templ' }, callback = vim.lsp.buf.format })
