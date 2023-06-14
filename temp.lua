local group = vim.api.nvim_create_augroup("BlameLine", {
  clear = true
})


local count = 1;

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    P("ho " .. count)
    count = count + 1
  end,
  group = group,
  buffer = 0,
})
