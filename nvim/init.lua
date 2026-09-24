-- bootstrap lazy.nvim
vim.opt.rtp:prepend("~/.local/share/nvim/lazy/lazy.nvim")

require("lazy").setup({
    -- Colorscheme
    {
        "rose-pine/neovim",
        config = function()
            vim.cmd([[colorscheme rose-pine]])
        end
    },

    -- Live preview per HTML
    {
        "brianhuster/live-preview.nvim",
        config = function()
            require("live-preview").setup({
                port = 8080,
                browser = "google-chrome-stable",
            })
        end
    },

    -- LSP + Mason
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "clangd", "pyright", "ts_ls" }
            })

            -- Aggiungi questo callback
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local buf = args.buf
                    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = buf, silent = true })
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buf, silent = true })
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = buf, silent = true })
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = buf, silent = true })
                end,
            })

            vim.lsp.config("clangd", {})
            vim.lsp.config("pyright", {})
            vim.lsp.config("ts_ls", {})

            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                underline = true,
                update_in_insert = false,
            })
        end 
    },

    -- Autocomplete LSP
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-j>"] = cmp.mapping.select_next_item(),
                    ["<C-k>"] = cmp.mapping.select_prev_item(),
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.confirm({ select = true })
                        else
                            fallback()
                        end
                    end),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }),
            })
        end,
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
        end
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            vim.treesitter.language.register("c", "c")
            require("nvim-treesitter.config").setup({
                ensure_installed = { "c", "python", "javascript", "lua", "html", "css" },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },

    {
        "stevearc/dressing.nvim",
        config = function()
            require("dressing").setup()
        end
    },
})

    -- Black background
    vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })

    -- Green comments
    vim.api.nvim_set_hl(0, "Comment", { fg = "#98c379", italic = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            vim.api.nvim_set_hl(0, "Comment", { fg = "#98c379", italic = true })
        end,
    })

    -- Editor options
    vim.opt.number = true
    vim.opt.relativenumber = false
    vim.opt.expandtab = true
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.smartindent = true
    vim.opt.cursorline = true
    vim.opt.wrap = false
    vim.opt.clipboard:append({"unnamed", "unnamedplus"})
    vim.opt.undofile = true

    -- Formatta il file con Black via `:Format`
    _G.format_with_black = function(mode)
        if vim.fn.executable("black") == 0 then
            vim.notify("black non trovato: pip install black", vim.log.levels.WARN)
            return
        end
        local buf = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local out = vim.fn.system("black -q -", table.concat(lines, "\n") .. "\n")
        if vim.v.shell_error ~= 0 then
            vim.notify("black: " .. out, vim.log.levels.ERROR)
            return
        end
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(out, "\n", { plain = true, trimempty = true }))
    end

    vim.api.nvim_create_user_command("Format", _G.format_with_black, { desc = "Formatta il buffer con Black" })

    -- Centra il cursore quando apri un file
    vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "*",
        callback = function()
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            local lcount = vim.api.nvim_buf_line_count(0)
            local line = math.min(mark[1], lcount)
            local col = mark[2]
            vim.api.nvim_win_set_cursor(0, {line, col})
            vim.cmd("normal! zz")
        end,
    })

    vim.opt.shada = "'100,<50,s10,h"
