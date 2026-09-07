Config.later(function()
  require('select-undo').setup {
    keymaps = {
      ['<cr>'] = 'accept',
      ['<esc>'] = 'cancel',
      ['n'] = 'next',
      ['N'] = 'previous',
    },
  }
end)
