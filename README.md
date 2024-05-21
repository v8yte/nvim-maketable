# nvim-maketable
This project is a fork of the original [vim-maketable](https://github.com/mattn/vim-maketable) plugin, which was originally written in Vimscript.

The purpose of this fork is to rewrite the plugin in Lua.

## Installation
### packer.nvim
```
    use({
        "v8yte/nvim-maketable",
        config = function ()
            require('nvim-maketable').setup({})
        end
    })
```
## Usage

Just select lines and do following

```
:'<,'>MakeTable
```

If you want to use first line as header of table,

```
:'<,'>MakeTable!
```

If you want to use tab separated columns,

```
:'<,'>MakeTable! \t
```

If you want to make CSV from markdown table

```
:UnmakeTable
```

## License

MIT

## Author

Buihachi Nishi (a.k.a coffeeCat)

## Original Author

[Yasuhiro Matsumoto (a.k.a mattn)](https://github.com/mattn/vim-maketable)
