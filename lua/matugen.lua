 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#091517',
    base01 = '#152223',
    base02 = '#202c2e',
    base03 = '#7c9599',
    base04 = '#b1cbcf',
    base05 = '#d7e5e7',
    base06 = '#d7e5e7',
    base07 = '#d7e5e7',
    base08 = '#ffb4ab',
    base09 = '#81d3dd',
    base0A = '#96d5a6',
    base0B = '#7dda9b',
    base0C = '#81d3dd',
    base0D = '#7dda9b',
    base0E = '#96d5a6',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#d7e5e7',          bg = '#091517' })
  hi('TelescopeBorder',         { fg = '#7c9599',             bg = '#091517' })
  hi('TelescopePromptNormal',   { fg = '#d7e5e7',          bg = '#091517' })
  hi('TelescopePromptBorder',   { fg = '#7c9599',             bg = '#091517' })
  hi('TelescopePromptPrefix',   { fg = '#7dda9b',             bg = '#091517' })
  hi('TelescopePromptCounter',  { fg = '#b1cbcf',  bg = '#091517' })
  hi('TelescopePromptTitle',    { fg = '#091517',             bg = '#7dda9b' })
  hi('TelescopePreviewTitle',   { fg = '#091517',             bg = '#96d5a6' })
  hi('TelescopeResultsTitle',   { fg = '#091517',             bg = '#81d3dd' })
  hi('TelescopeSelection',      { fg = '#d7e5e7',          bg = '#202c2e' })
  hi('TelescopeSelectionCaret', { fg = '#7dda9b',             bg = '#202c2e' })
  hi('TelescopeMatching',       { fg = '#7dda9b',             bold = true })
end

 -- Register a signal handler for SIGUSR1 (matugen updates)
 local signal = vim.uv.new_signal()
 signal:start(
   'sigusr1',
   vim.schedule_wrap(function()
     package.loaded['matugen'] = nil
     require('matugen').setup()
   end)
 )

 return M
