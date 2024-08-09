call plug#begin()
Plug 'nvim-lua/plenary.nvim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'rust-lang/rust.vim'
Plug 'arzg/vim-rust-syntax-ext'
Plug 'davemo88/rust-fade'
Plug 'leafgarland/typescript-vim'
Plug 'tomlion/vim-solidity'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'simrat39/rust-tools.nvim'
Plug 'mfussenegger/nvim-dap'
Plug 'mfussenegger/nvim-dap-python'
Plug 'rcarriga/nvim-dap-ui'
Plug 'jackMort/ChatGPT.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'MunifTanjim/nui.nvim',
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'othree/html5.vim'
Plug 'pangloss/vim-javascript'
Plug 'evanleck/vim-svelte', {'branch': 'main'}
call plug#end()

lua require'lspconfig'.tsserver.setup {}

lua require'lspconfig'.rust_analyzer.setup{}
lua require('dap-python').setup('~/.virtualenvs/debugpy/bin/python')
lua require'lspconfig'.pyright.setup{}

filetype plugin indent on
colorscheme fade 

function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
	
set expandtab
set shiftwidth=4
set tabstop=4
autocmd FileType svelte set shiftwidth=2
autocmd FileType svelte set tabstop=2

let mapleader = ","
nnoremap <silent> <leader>f :FZF<cr>
nnoremap <silent> <leader>F :FZF ~<cr>
nnoremap <silent> <leader>r :Rg<cr>
" nnoremap <silent> <leader>g :Rg<cr>
nnoremap <silent> <leader>t :Tags<cr>
let $FZF_DEFAULT_COMMAND='fd --type f'
command W w
command Q q
map <silent> <leader>/ :s/^/\/\//<cr>

set pastetoggle=<F2>
" clipboard
vnoremap <leader>y "+y
nnoremap <leader>Y "+yg_
nnoremap <leader>y "+y
nnoremap <leader>yy "+yy
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P

" Set completeopt to have a better completion experience
" :help completeopt
" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect

" Avoid showing extra messages when using completion
set shortmess+=c

" Configure LSP through rust-tools.nvim plugin.
" rust-tools will configure and enable certain LSP features for us.
" See https://github.com/simrat39/rust-tools.nvim#configuration
lua <<EOF
local nvim_lsp = require'lspconfig'
local rt = require("rust-tools")

require'lspconfig'.rust_analyzer.setup({
    settings = {
        ["rust-analyzer"] = {
	    cargo = {
		unsetTest = {
		    "core", "ed25519-dalek"
		}
	    }
        }
    }
})

local opts = {
    tools = { -- rust-tools options
        autoSetHints = true,
        inlay_hints = {
            show_parameter_hints = true,
            parameter_hints_prefix = "",
            other_hints_prefix = "",
        },
    },

    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
    server = {
        settings = {
            -- to enable rust-analyzer settings visit:
            -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
            ["rust-analyzer"] = {
                -- enable clippy on save
                checkOnSave = {
                    command = "clippy"
                },
            }
        },
	on_attach = function(_, bufnr)
	    -- Hover actions
      	    vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      	    -- Code action groups
      	    vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
     	end,
    },
}

require('rust-tools').setup(opts)
EOF

" Setup Completion
" See https://github.com/hrsh7th/nvim-cmp#basic-configuration
lua <<EOF
local cmp = require'cmp'
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },

  -- Installed sources
  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'path' },
    { name = 'buffer' },
  },
})
EOF
nnoremap <Space> <NOP>

" Code navigation shortcuts
nnoremap <silent> <c-]> 	<cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     	<cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    	<cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> 	<cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> gn 		<cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    	<cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    	<cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    	<cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> gd    	<cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> ga    	<cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> gR    	<cmd>lua vim.lsp.buf.rename()<CR>

" Set updatetime for CursorHold
" 300ms of no cursor movement to trigger CursorHold
set updatetime=300
" Show diagnostic popup on cursor hold
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })

" Goto previous/next diagnostic warning/error
nnoremap <silent> g[ <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> g] <cmd>lua vim.diagnostic.goto_next()<CR>

" have a fixed column for the diagnostics to appear in
" this removes the jitter when warnings/errors flow in
set signcolumn=yes

"autocmd BufWritePre *.rs lua vim.lsp.buf.formatting_sync(nil, 200)

" let g:rustfmt_autosave = 1
set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
set grepformat=%f:%l:%c:%m
