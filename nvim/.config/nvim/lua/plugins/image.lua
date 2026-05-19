return {
  "3rd/image.nvim", --  INFO: has limited support on WezTerm, works better in Ghostty
  build = false,
  opts = {
    backend = "kitty",
    processor = "magick_cli",
    -- image file preview
    hijack_file_patterns = {
      "*.png",
      "*.jpg",
      "*.jpeg",
      "*.gif",
      "*.webp",
      "*.avif",
      "*.svg",
    },
  },
}
