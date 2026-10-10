vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'tpope/vim-surround',
  'ojroques/vim-oscyank',
  'nyoom-engineering/oxocarbon.nvim',
  {
    'ThePrimeagen/git-worktree.nvim',
    config = function()
      require("git-worktree").setup({
        change_directory_command = "cd"
      })
    end
  },
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  },
  'nvim-neotest/nvim-nio',
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = {} },
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>lf", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    }
  },
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('diffview').setup({
        enhanced_diff_hl = true,
        view = {
          -- Merge tool layout
          merge_tool = {
            layout = "diff3_horizontal",
            disable_diagnostics = true, -- cleaner while merging
          },
        },
      })
    end,
  },
  'matze/vim-move',
  'BurntSushi/ripgrep',
  'windwp/nvim-autopairs',
  'airblade/vim-gitgutter',
  'Olical/conjure',
  'tpope/vim-sleuth',
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      ui = {
        enable = false,
      },
      workspaces = {
        {
          name = "personal",
          path = "~/vaults/personal",
        },
        {
          name = "study",
          path = "~/vaults/study",
        },
      },
    },
  },
  {
    'NvChad/nvim-colorizer.lua',
    name = 'colorizer',
    config = function()
      require('colorizer').setup({
        user_default_options = {
          tailwind = true,
        }
      })
    end
  },
  {
    'andweeb/presence.nvim',
    name = "presence",
    config = function()
      require("presence").setup({
        neovim_image_text = "mrreowwwf~ :3",
      })
    end
  },
  {
    'nvimdev/lspsaga.nvim',
    event = 'LspAttach',
    config = function()
      require('lspsaga').setup({
        ui = {
          border = 'rounded',
          code_action = '',
          devicon = false,
          title = false,
        },
        hover = {
          max_width = 0.95,
          max_height = 0.9,
          open_link = 'gx',
        },
        lightbulb = {
          enable = false,
        },
        symbol_in_winbar = {
          enable = false,
        },
      })
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', config = true },
      'mason-org/mason-lspconfig.nvim',

      { 'j-hui/fidget.nvim',    tag = 'legacy', opts = {} },

      'folke/neodev.nvim',
    },
    opts = {
      servers = {
        rust_analyzer = {
          keys = {
            { "K",          "<cmd>RustHoverActions<cr>", desc = "Hover Actions (Rust)" },
            { "<leader>cR", "<cmd>RustCodeAction<cr>",   desc = "Code Action (Rust)" },
            { "<leader>dr", "<cmd>RustDebuggables<cr>",  desc = "Run Debuggables (Rust)" },
          },
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
            },
          },
        },
        taplo = {
          keys = {
            {
              "K",
              function()
                if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
                  require("crates").show_popup()
                else
                  vim.lsp.buf.hover()
                end
              end,
              desc = "Show Crate Documentation",
            },
          },
        },
      },
    },
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'rafamadriz/friendly-snippets',
      { 'roobert/tailwindcss-colorizer-cmp.nvim', config = true }
    },
    opts = function(_, opts)
      opts.formatting = {
        format = require("tailwindcss-colorizer-cmp").formatter
      }
    end
  },

  { 'folke/which-key.nvim',     opts = {} },
  {
    'stevearc/dressing.nvim',
    lazy = false,
    opts = {
      select = {
        backend = { 'builtin' },
        builtin = {
          border = 'rounded',
          relative = 'cursor',
          max_width = 0.5,
          max_height = 0.5,
        },
      },
      input = {
        border = 'rounded',
      },
    },
  },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      current_line_blame = true,
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>hp', require('gitsigns').preview_hunk, { buffer = bufnr, desc = 'Preview git hunk' })

        -- don't override the built-in and fugitive keymaps
        local gs = package.loaded.gitsigns
        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = "Jump to previous hunk" })
      end,
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        flavour = "latte",
      }
    end
  },

  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        styles = {
          bold = true,
          italic = true,
          transparency = true,
        },
        palette = {
          moon = {
            love = "#b4637a",
            gold = "#fcb6bf",
            rose = "#c4b5fd",
            none = "NONE",
          }

        }
      })
    end
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    event = "VeryLazy",
    -- See `:help lualine.txt`
    dependencies = { "kyazdani42/nvim-web-devicons", opt = true },
    config = function()
      local custom_horizon = require('lualine.themes.horizon')
      local light_rose = '#fcb6bf'
      custom_horizon.insert.a.bg = "#c4b5fd"

      custom_horizon.insert.c.fg = light_rose
      custom_horizon.normal.c.fg = light_rose
      custom_horizon.command.c.fg = light_rose
      custom_horizon.visual.c.fg = light_rose
      custom_horizon.replace.c.fg = light_rose
      custom_horizon.inactive.c.fg = light_rose

      custom_horizon.insert.c.bg = "NONE"
      custom_horizon.normal.c.bg = "NONE"
      custom_horizon.command.c.bg = "NONE"
      custom_horizon.visual.c.bg = "NONE"
      custom_horizon.replace.c.bg = "NONE"
      custom_horizon.inactive.c.bg = "NONE"

      custom_horizon.insert.b.fg = light_rose
      custom_horizon.normal.b.fg = light_rose
      custom_horizon.command.b.fg = light_rose
      custom_horizon.visual.b.fg = light_rose
      custom_horizon.replace.b.fg = light_rose
      custom_horizon.inactive.b.fg = light_rose


      local function avante_chat()
        if not avante_status then
          local ok, mod = pcall(require, "avante-status.lualine")
          if ok then avante_status = mod else return "" end
        end
        local ok, out = pcall(avante_status.chat_component)
        return ok and out or ""
      end

      local function avante_suggest()
        if not avante_status then
          local ok, mod = pcall(require, "avante-status.lualine")
          if ok then avante_status = mod else return "" end
        end
        local ok, out = pcall(avante_status.suggestions_component)
        return ok and out or ""
      end

      require('lualine').setup {
        options = {
          icons_enabled = false,
          theme = custom_horizon,
          component_separators = '|',
          section_separators = '|',
        },
        sections = {
          lualine_x = { "encoding", "fileformat", "filetype", "vim.fn.fnamemodify(vim.fn.expand('%:h'), ':p:~:.')", avante_chat, avante_suggest }
        }
      }
    end
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    main = "ibl",
    opts = {}
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    config = function()
      require('telescope').setup {
        defaults = {
          file_ignore_patterns = {
            "node_modules"
          }
        }
      }

      require('telescope').load_extension("git_worktree")
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    lazy = false,
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'master' },
    },
    build = ':TSUpdate',
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  require 'kickstart.plugins.autoformat',
  require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})

vim.cmd("colorscheme oxocarbon")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#fcb6bf", bg = "none" })
vim.api.nvim_set_hl(0, "HoverBorder", { fg = "#fcb6bf", bg = "none" })
vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#fcb6bf", bg = "none" })
vim.api.nvim_set_hl(0, "CmpDocBorder", { fg = "#fcb6bf", bg = "none" })
vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "FoldColumn", { bg = "none" })
-- Status line transparency
vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
-- Other UI elements
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" })
vim.api.nvim_set_hl(0, "VertSplit", { bg = "none" })
-- Git signs column
vim.api.nvim_set_hl(0, "GitSignsAdd", { bg = "none" })
vim.api.nvim_set_hl(0, "GitSignsChange", { bg = "none" })
vim.api.nvim_set_hl(0, "GitSignsDelete", { bg = "none" })
-- Diagnostic virtual text - muted colors matching oxocarbon aesthetic
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#82aaff", bg = "none" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#7dcfff", bg = "none" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#e0af68", bg = "none" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#ee5396", bg = "none" })
-- Inlay hints - subtle gray to not distract from code
vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#525252", bg = "none", italic = true })

-- Constants - oxocarbon defaults these to purple; prefer a light yellow (e.g. DEFAULT_INTERVAL = 5.0)
local constant_fg = "#f9e2af"
vim.api.nvim_set_hl(0, "Constant", { fg = constant_fg })
vim.api.nvim_set_hl(0, "@constant", { fg = constant_fg })
vim.api.nvim_set_hl(0, "@constant.builtin", { fg = constant_fg })
vim.api.nvim_set_hl(0, "@constant.macro", { fg = constant_fg })

local string_fg = "#e8b7ff"
vim.api.nvim_set_hl(0, "String", { fg = string_fg })
vim.api.nvim_set_hl(0, "@string", { fg = string_fg })
vim.api.nvim_set_hl(0, "@string.documentation", { fg = string_fg })

-- Enable inlay hints by default
vim.lsp.inlay_hint.enable(true)
-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true
vim.o.relativenumber = true

-- Vertical right open file default
vim.o.splitright = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
--
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}

vim.keymap.set('n', '<leader>c', '<Plug>OSCYankOperator')
vim.keymap.set('n', '<leader>cc', '<leader>c_', { remap = true })
vim.keymap.set('v', '<leader>c', '<Plug>OSCYankVisual')

vim.keymap.set('n', '<leader>ci', function()
  vim.api.nvim_feedkeys('a', 'n', false) -- Enter insert mode
  vim.schedule(function()
    local cmp = require('cmp')
    cmp.complete() -- Trigger nvim-cmp completion
  end)
end, { desc = 'Completion at cursor' })


-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set({ 'n', 'v' }, '<leader>y', function()
  vim.cmd("OSCYank")
end, { desc = "Yank to system clipboard via OSC52" })

-- remap for vim-move
local vim_move_opts = { silent = true, noremap = true }
vim.keymap.set('v', '<C-Up>', '<Plug>MoveBlockUp', vim_move_opts)
vim.keymap.set('v', '<C-Down>', '<Plug>MoveBlockDown', vim_move_opts)
vim.keymap.set('v', '<C-Right>', '<Plug>MoveBlockRight', vim_move_opts)
vim.keymap.set('v', '<C-Left>', '<Plug>MoveBlockLeft', vim_move_opts)

vim.keymap.set('n', '<C-Up>', '<Plug>MoveLineUp', vim_move_opts)
vim.keymap.set('n', '<C-Down>', '<Plug>MoveLineDown', vim_move_opts)
vim.keymap.set('n', '<C-Left>', '<Plug>MoveCharLeft', vim_move_opts)
vim.keymap.set('n', '<C-Right>', '<Plug>MoveCharRight', vim_move_opts)

-- Pane navigation with <leader>e + direction (Colemak-style)
vim.keymap.set('n', '<leader>en', '<C-w>h', { desc = 'Move to left pane' })
vim.keymap.set('n', '<leader>eu', '<C-w>k', { desc = 'Move to upper pane' })
vim.keymap.set('n', '<leader>ee', '<C-w>j', { desc = 'Move to lower pane' })
vim.keymap.set('n', '<leader>ea', '<C-w>l', { desc = 'Move to right pane' })


-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf',
  require('telescope.builtin').find_files,
  { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sa',
  function()
    require('telescope.builtin').find_files({ find_command = { 'rg', '--files', '--hidden', '-g', '!.git' } })
  end,
  { desc = '[S]earch [A]ll files' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]resume' })
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = '[F]ormat current buffer' })


vim.keymap.set('n', '<leader>go', '<cmd>DiffviewOpen<cr>', { desc = '[G]it: Diffview [O]pen' })
vim.keymap.set('n', '<leader>gq', '<cmd>DiffviewClose<cr>', { desc = '[G]it: Diffview [Q]uit' })
vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory<cr>', { desc = '[G]it: Diffview [H]istory (file or repo)' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'cpp', 'dockerfile', 'html', 'go', 'lua', 'markdown', 'markdown_inline', 'python', 'rust', 'tsx', 'javascript',
    'typescript', 'svelte', 'yaml', 'vimdoc', 'vim' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,

  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>eq', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Configure diagnostics to appear inline (virtual text)
vim.diagnostic.config({
  virtual_text = true, -- This is the key setting for inline diagnostics
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
  },
})

-- Add rounded borders to LSP floating windows (hover, signature help)
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'rounded',
})
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = 'rounded',
})
vim.lsp.handlers['textDocument/codeAction'] = vim.lsp.with(vim.lsp.handlers['textDocument/codeAction'], {
  border = 'rounded',
})

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  -- Enable inlay hints for this buffer if the server supports it
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  local has_saga = pcall(require, 'lspsaga')
  if has_saga then
    nmap('<leader>i', '<cmd>Lspsaga hover_doc<CR>', 'Hover Documentation')
    nmap('<leader>ca', '<cmd>Lspsaga code_action<CR>', '[C]ode [A]ction')
  else
    nmap('<leader>i', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  end
  nmap('<leader>I', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')


  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  clangd = {},
  -- gopls = {},
  pyright = {
    root_markers = { "pyproject.toml", ".git" },
  },
  ruff = {
    root_markers = { "pyproject.toml", "ruff.toml", ".git" },
    on_attach = function(client, bufnr)
      -- defer real language features to ty
      client.server_capabilities.hoverProvider = false
      client.server_capabilities.definitionProvider = false
      client.server_capabilities.referencesProvider = false

      on_attach(client, bufnr)
    end,
  },
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
require("cmp").config.formatting = {
  format = require("tailwindcss-colorizer-cmp").formatter
}


-- Ensure the servers above are installed
require("mason").setup()
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
  automatic_enable = false,
}

for server_name, server_opts in pairs(servers) do
  vim.lsp.config(server_name, vim.tbl_deep_extend("force", {
    capabilities = capabilities,
    on_attach = on_attach,
  }, server_opts or {}))
end

vim.lsp.enable(vim.tbl_keys(servers))
-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
