-- ============================================================================
-- Bootstrap lazy.nvim
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- Plugin Setup
-- ============================================================================
require("lazy").setup({
  ------- fzf
  {
    'junegunn/fzf',
		build = ':call fzf#install()',
  },
  {
    'junegunn/fzf.vim',
    dependencies = { 'junegunn/fzf' },
    keys = {
      { '<C-p>', '<cmd>Files<cr>', desc = 'Find files' },
      { '<C-g>', '<cmd>Rg<cr>', desc = 'Grep search' },
      { '<leader>b', '<cmd>Buffers<cr>', desc = 'Find buffers' },
    },
  },

	  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      -- mason setup（LSPサーバーのインストーラー）
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = { 'ts_ls', 'gopls' },
        automatic_installation = true,
      })

      -- TypeScript
      vim.lsp.config('ts_ls', {
        filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
      })

			-- Golang
			vim.lsp.config('gopls', {
  			filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
			})

      -- TypeScript/JavaScriptファイルでLSP有効化
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
        callback = function()
          vim.lsp.enable('ts_ls')
        end,
      })

			-- GoファイルでLSP有効化（新規追加）
			vim.api.nvim_create_autocmd('FileType', {
  			pattern = { 'go', 'gomod', 'gowork', 'gotmpl' },
  			callback = function()
    			vim.lsp.enable('gopls')
  			end,
			})

      -- LSPキーマップ（バッファにLSPがアタッチされたときに設定）
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
    			local client = vim.lsp.get_client_by_id(args.data.client_id)

    			-- セマンティックトークンを無効化（Tree-sitterに任せる）
    			if client then
      			client.server_capabilities.semanticTokensProvider = nil
    			end

          local opts = { buffer = args.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },

	------- 補完
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',     -- LSP補完
      'hrsh7th/cmp-buffer',       -- バッファ内の単語補完
      'hrsh7th/cmp-path',         -- パス補完
      'L3MON4D3/LuaSnip',         -- スニペットエンジン
      'saadparwaiz1/cmp_luasnip', -- スニペット補完
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Enterで確定
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },

  -- Tree-sitter（シンタックスハイライト強化）
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local ok, configs = pcall(require, 'nvim-treesitter.configs')
      if not ok then
        return
      end
      
      configs.setup({
        ensure_installed = { 'typescript', 'tsx', 'javascript', 'lua', 'go' },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })
    end,
  },

	-- Rainbow括弧（モダン版）
  {
    'HiPhish/rainbow-delimiters.nvim',
		init = function()
    local rainbow_delimiters = require("rainbow-delimiters")

    vim.g.rainbow_delimiters = {
			strategy = {
        [""] = "rainbow-delimiters.strategy.global",
      },
      query = {
        [""] = "rainbow-delimiters",
      },
      priority = {
        [""] = 210,
      },
      highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
      },
    }
  	end,
	config = function()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        local colors = {
          Red    = "#E06C75",
          Yellow= "#E5C07B",
          Blue   = "#61AFEF",
          Orange = "#D19A66",
          Green  = "#98C379",
          Violet = "#C678DD",
          Cyan   = "#56B6C2",
        }

        for name, color in pairs(colors) do
          vim.api.nvim_set_hl(
            0,
            "RainbowDelimiter" .. name,
            { fg = color }
          )
        end
      end,
    })

    -- default colorscheme 対策（すでに読み込まれてた分）
    if vim.g.colors_name then
      vim.cmd.colorscheme(vim.g.colors_name)
    end
  end,
  },

	------- CSV
	{
  'mechatroner/rainbow_csv',
  ft = { 'csv', 'tsv' },
	},

}, {
  -- lazy.nvimの設定（オプション）
  checker = { enabled = true }, -- 自動アップデートチェック
})

-- ============================================================================
-- Global Settings
-- ============================================================================

-- 基本設定
vim.opt.title = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrapscan = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.clipboard:append('unnamed')

-- LSP ログ設定
vim.g.lsp_log_verbose = 1
vim.g.lsp_log_file = vim.fn.stdpath("log") -- ~/.local/state/nvim/lsp.log

-- 背景を透過（ターミナルのテーマを使用）
vim.cmd([[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NonText guibg=NONE ctermbg=NONE
  highlight LineNr guibg=NONE ctermbg=NONE
  highlight SignColumn guibg=NONE ctermbg=NONE
  highlight EndOfBuffer guibg=NONE ctermbg=NONE
]])

-- ハイライト設定
vim.cmd([[
  highlight LineNr ctermfg=244
  highlight Pmenu      ctermfg=189 ctermbg=235 guifg=#cdd6f4 guibg=#1e1e2e
  highlight PmenuSel   ctermfg=16 ctermbg=117 guifg=#11111b guibg=#89b4fa
  highlight PmenuSbar  ctermbg=238 guibg=#45475a
  highlight PmenuThumb ctermbg=117 guibg=#89b4fa
]])

-- Quickfixをバッファリストに表示しない
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  callback = function()
    vim.opt_local.buflisted = false
  end,
})

-- ============================================================================
-- Cheat Sheet
-- ============================================================================
local function open_cheatsheet()
  vim.cmd("botright new")
  local buf = vim.api.nvim_get_current_buf()

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = false
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.bo[buf].filetype = "help"

  local lines = {
    " nvim Cheat Sheet ",
    "------------------",
    "",
    "基本",
    ":q            - Quit",
    ":w            - Save",
    ":wq           - Save and Quit",
    "dd            - Delete line",
    "yy            - Copy line",
    "p             - Paste",
    "u             - Undo",
    "Ctrl-r        - Redo",
    "Ctrl-w        - Window移動",
    "",
    "検索",
    "n             - 次の検索結果",
    "N             - 前の検索結果",
    "*             - 今いる単語を検索",
    "",
    "FZF (fzf.vim)",
    "Ctrl-p        - Files (ファイル検索)",
    "Ctrl-g        - Rg (ripgrep 検索)",
    "leader + b    - Buffers (バッファ検索)",
    "",
    "LSP",
    "gd            - 定義へジャンプ",
    "gr            - 参照(使用箇所)検索",
    "gi            - 実装へジャンプ",
    "gt            - 型定義へジャンプ",
    "K             - Hover (docs表示)",
    "leader + rn   - Rename",
    "leader + ca   - Code Action",
    "Ctrl-o        - ジャンプ先から戻る",
    "",
    "LSP/Mason",
    ":Mason        - LSPサーバ等の管理画面",
    ":LspInfo      - LSP 接続状況",
    "",
    "補完 (nvim-cmp) ※Insertモード",
    "Ctrl-Space    - 補完候補を出す",
    "Enter         - 確定",
    "Ctrl-e        - 補完を閉じる",
    "Tab / S-Tab   - 候補移動 / Snippetジャンプ",
    "",
    "Press ENTER to close",
  }

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  vim.keymap.set("n", "<CR>", "<cmd>q<CR>", { buffer = buf, silent = true })
end

vim.api.nvim_create_user_command("Th", open_cheatsheet, {})

