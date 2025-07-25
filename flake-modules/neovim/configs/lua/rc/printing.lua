vim.api.nvim_create_user_command("Print", function()
  -- TODO: Make this work with a visual range
  vim.api.nvim_command("w !lp -n 1 -o media=a4 -o orientation-requested=1 -d HP_OfficeJet_4650_series_A89900")
end, {})
