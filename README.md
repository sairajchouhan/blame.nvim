<div align="center">

# blame.nvim

Neovim plugin for showing git blame written in lua

![Screen_Recording_2023-06-20_at_1_59_10_PM_AdobeExpress](https://github.com/sairajchouhan/blame.nvim/assets/57995897/0897bd72-7354-475c-b546-36dfeeafea35)


</div>


## Installation & Usage

- [lazy.nvim](https://github.com/folke/lazy.nvim)

  ```lua
  {
    "sairajchouhan/blame.nvim",
    opts = {},
  }
  ```

- [packer.nvim](https://github.com/wbthomason/packer.nvim)

  ```lua
  use({
    "sairajchouhan/blame.nvim",
    config = function()
      require("blame").setup()
    end,
  })
  ```

## Commands
There are 4 user commands

- `BlameLine` - shows git blame of current line and updates blame if cursor position changes
- `BlameLineOff` - turns of the git blame
- `BlameLineToggle` - toggles blame on and off
- `BlameLineOnce` - shows blame for current line just once, does not update blame when cursor position changes;
