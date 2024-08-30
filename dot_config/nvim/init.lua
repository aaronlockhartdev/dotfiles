-----Vim Options-----
local set = vim.opt

-- Line numbers
set.number = true
set.relativenumber = true

-- Cursor
set.cursorline = true
set.cursorcolumn = true

-- Tabs
set.shiftwidth=4
set.tabstop=4
set.expandtab = true

-- Searching
set.incsearch = true
set.showmatch = true
set.hlsearch = true
set.ignorecase = true
set.smartcase = true

-- Vim commands
set.wildmenu = true
set.wildmode = "list:longest"
set.wildignore = "*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx"

-- Code folding
set.foldmethod = "expr"
set.foldexpr = "nvim_treesitter#foldexpr()"
set.foldenable = false

-- Miscallaneous
set.writebackup = false
set.scrolloff = 10
set.wrap = true
set.history = 1000
set.conceallevel = 2
set.signcolumn = "yes"

-----Plugins-----

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin installation
require("lazy").setup({
    { "lervag/vimtex" },
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-cmdline" },
    { "hrsh7th/nvim-cmp" },
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" } 
    },
    { 
        "nvim-treesitter/nvim-treesitter", 
        build = ":TSUpdate",
        config = function () 
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html", "python" },
                sync_install = false,
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },  
            })
        end
    },
    { "lukas-reineke/indent-blankline.nvim" },
    { "numToStr/Comment.nvim", opts = {}, lazy = false },
    { 
        "nvim-lualine/lualine.nvim",
        dependencies = { 'nvim-tree/nvim-web-devicons' } 
    },
    { "nvim-tree/nvim-tree.lua" },
    { "lervag/vimtex", lazy = false, ft = 'tex'},
    { "catppuccin/nvim" }
})

-- Set colorscheme
vim.cmd("colorscheme catppuccin-macchiato")

-- Lazy load friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

-- Configure numToStr/Comment
require('Comment').setup()

-- Configure LSPs
local lspconfig = require('lspconfig')
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.jedi_language_server.setup{
    capabilities = lsp_capabilities
}

lspconfig.tsserver.setup{
    capabilities = lsp_capabilities
}

lspconfig.svelte.setup{
    capabilities = lsp_capabilities
}

lspconfig.dockerls.setup{
    capabilities = lsp_capabilities
}

lspconfig.tailwindcss.setup{
    capabilities = lsp_capabilities
}

lspconfig.rust_analyzer.setup{
    capabilities = lsp_capabilities
}

vim.filetype.add({ 
    extension = {
        pcss = 'postcss'
    }
})
vim.treesitter.language.register('scss', { 'postcss' })

-- Configure nvim-cmp and LuaSnip
set.completeopt = {'menu', 'menuone', 'noselect'}

local cmp = require('cmp')
local luasnip = require('luasnip')

local select_opts = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end
    },
    sources = {
        {name = 'path'},
        {name = 'nvim_lsp', keyword_length = 1},
        {name = 'buffer', keyword_length = 3},
        {name = 'luasnip', keyword_length = 2},
    },
    window = {
        documentation = cmp.config.window.bordered()
    },
    formatting = {
        fields = {'menu', 'abbr', 'kind'},
        format = function(entry, item)
            local menu_icon = {
                nvim_lsp = '󰙲',
                luasnip = '',
                buffer = '',
                path = '',
            }

            item.menu = menu_icon[entry.source.name]
            return item
        end
    },
    mapping = {
        ['<CR>'] = cmp.mapping.confirm({select = false}),

        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),

        ['<C-e>'] = cmp.mapping.abort(),
        ['<C-y>'] = cmp.mapping.confirm({select = true}),
        ['<CR>'] = cmp.mapping.confirm({select = false}),

        ['<C-f>'] = cmp.mapping(function(fallback)
            if luasnip.jumpable(1) then
                luasnip.jump(1)
            else
                fallback()
            end
        end, {'i', 's'}),

        ['<C-b>'] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, {'i', 's'}),

        ['<Tab>'] = cmp.mapping(function(fallback)
            local col = vim.fn.col('.') - 1

            if cmp.visible() then
                cmp.select_next_item(select_opts)
            elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                fallback()
            else
                cmp.complete()
            end
        end, {'i', 's'}),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item(select_opts)
            else
                fallback()
            end
        end, {'i', 's'}),
    }
})

local sign = function(opts)
    vim.fn.sign_define(opts.name, {
        texthl = opts.name,
        text = opts.text,
        numhl = ''
    })
end

sign({name = 'DiagnosticSignError', text = '✘'})
sign({name = 'DiagnosticSignWarn', text = '▲'})
sign({name = 'DiagnosticSignHint', text = '⚑'})
sign({name = 'DiagnosticSignInfo', text = '»'})

vim.diagnostic.config({
    severity_sort = true,
    virtual_text = {
        source = 'if-many',
        prefix = '󰧟',
    },
    float = {
        border = 'rounded',
        source = 'always',
    },
})

-- Configure LuaLine
require('lualine').setup()

-- Configure VimTex
vim.g.vimtex_view_method = "skim"

-----Mappings-----
-- Set mapleader
vim.g.mapleader = ","

-- Set mappings
local map = vim.keymap.set

-- Easier escape
map("i", "Jj", "<esc>")

-- Center cursor during search
map("n", "n", "nzz")
map("n", "N", "Nzz")

-- Use spacebar instead of : for commands
map("n", "<space>", ":")

-- Open file tree with <leader>b
map("", "<leader>b", ":NvimTreeFocus<CR>")

-- Diagnostic mappings
map('n', '<space>e', vim.diagnostic.open_float)
map('n', '[d', vim.diagnostic.goto_prev)
map('n', ']d', vim.diagnostic.goto_next)
map('n', '<space>q', vim.diagnostic.setloclist)

-- Navigate between panes
map("n", "<C-k>", ":wincmd k<CR>")
map("n", "<C-j>", ":wincmd j<CR>")
map("n", "<C-h>", ":wincmd h<CR>")
map("n", "<C-l>", ":wincmd l<CR>")
