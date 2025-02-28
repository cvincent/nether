return {
  "3rd/image.nvim",
  opts = {
    processor = "magick_cli",
    window_overlap_clear_enabled = true,
    window_overlap_clear_ft_ignore = {},
    integrations = {
      markdown = {
        resolve_image_path = function(document_path, image_path)
          return "/backup/second-brain/" .. image_path
        end,
      }
    }
  }
}
