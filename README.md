# ghostty-fonts.nvim

[GhosttyFonts.webm](https://github.com/user-attachments/assets/7e9311fe-f76f-426c-953d-fc92b6c33214)

Neovim module to preview and apply system fonts to Ghostty terminal.

It is a work around to change fonts in Ghostty in a faster way.

## Features
- Real-time font preview via Telescope.
- Instant configuration reload via SIGUSR2.
- Automatic monospace detection.

## Requirements
- Ghostty Terminal
- Neovim (v0.8+)
- telescope.nvim
- fontconfig (fc-list)

## Installation (Lazy.nvim)

```lua
{
    "mazzoccantelorenzo/ghostty-fonts.nvim",
    cmd = { "GhosttyFonts", "FontFamily", "FontSize" },
    config = function()
        require("ghostty-fonts").setup()
    end,
}
```

## Usage

### Interactive Picker
Run `:GhosttyFonts` to open the Telescope picker.
- `<Up>`/`<Down>` or `<Tab>`/`<S-Tab>`: Live preview.
- `<Enter>`: Apply and close.
- `<Esc>`: Exit.

### Direct Commands
Apply changes directly without opening the picker:
- `:FontFamily <fontname>`: Set a specific font family.
- `:FontSize <number>`: Set a specific font size.

## Silent Mode
To disable Ghostty's reload notifications, update your Ghostty config:

```ini
desktop-notifications = false
```
