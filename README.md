# dendrite.nvim

A Neovim plugin for managing a local markdown vault, powered by [dendrite.daemon](https://kristianjborgwarth.github.io/dendrite.docs/).

For full documentation, visit the [Dendrite docs](https://kristianjborgwarth.github.io/dendrite.docs/).

## Requirements

- [dendrite.daemon](https://github.com/KristianJBorgwarth/dendrite.daemon) — install it first:

```sh
curl -fsSL https://raw.githubusercontent.com/KristianJBorgwarth/dendrite.daemon/master/install.sh | sh
```

- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (optional, for link completion)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "KristianJBorgwarth/dendrite.nvim",
  config = function()
    require("dendrite").setup({
      vault_name = "my-vault",
      vault_path = "~/my-vault",
      templates_dir = "/.templates",
      daily_notes = {
        dir = "/daily",
        filename_format = "%Y-%m-%d.md",
        template_name = "daily",
      },
      scratch_notes = {
        dir = "/scratches",
        template_name = "scratch",
      },
    })
  end,
}
```
