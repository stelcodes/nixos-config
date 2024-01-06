{ pkgs, lib, config, systemConfig, ... }:
let
  theme = systemConfig.theme.set;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withPython3 = false;
    withNodeJs = false;
    withRuby = false;
    extraLuaConfig = builtins.readFile ./base.lua;
    extraPackages = lib.lists.optionals systemConfig.activities.coding [
      pkgs.clojure-lsp
      pkgs.rnix-lsp
      pkgs.pyright
      pkgs.nodePackages.typescript-language-server
      pkgs.rust-analyzer
      pkgs.java-language-server
      pkgs.lua-language-server
    ];
    plugins =
      let
        hydropump-nvim = pkgs.vimUtils.buildVimPlugin {
          pname = "hydropump-nvim";
          version = "1.0";
          src = pkgs.fetchFromGitHub {
            owner = "stelcodes";
            repo = "hydropump.nvim";
            rev = "77c400821f387a4d36dd60c68d7a6aeac990eafc";
            sha256 = "XK/RAe1LFf0I892COxJXGfjBBzpwBVxECEokYqBNwag=";
          };
        };

        stel-paredit = pkgs.vimUtils.buildVimPlugin {
          pname = "stel-paredit";
          version = "1.0";
          src = pkgs.fetchFromGitHub {
            owner = "stelcodes";
            repo = "paredit";
            rev = "27d2ea61ac6117e9ba827bfccfbd14296c889c37";
            sha256 = "1bj5m1b4n2nnzvwbz0dhzg1alha2chbbdhfhl6rcngiprbdv0xi6";
          };
        };

        nnn-nvim = pkgs.vimUtils.buildVimPlugin {
          pname = "nnn-nvim";
          version = "unstable-2023-11-30";
          src = pkgs.fetchFromGitHub {
            owner = "luukvbaal";
            repo = "nnn.nvim";
            rev = "4616ec65eb0370af548e356c3ec542c1b167b415";
            sha256 = "iJTN1g5uoS6yj0CZ6Q5wsCAVYVim5zl4ObwVyLtJkQ0=";
          };
        };

      in
      [
        # Theme plugin should go first because it sets local vars like lualine_theme
        theme.neovimPlugin

        {
          plugin = pkgs.vimPlugins.vim-fugitive;
          type = "lua";
          config = /* lua */ ''
            vim.keymap.set('n', '<c-g>', '<cmd>Git<cr><c-w>H')
            vim.keymap.set('n', '<leader>gD', '<cmd>Git difftool<cr>')
          '';
        }

        {
          plugin = stel-paredit;
          type = "lua";
          config = /* lua */ ''
            vim.g['paredit_smartjump'] = 1
            vim.g['paredit_matchlines'] = 500
          '';
        }

        pkgs.vimPlugins.plenary-nvim
        pkgs.vimPlugins.telescope-file-browser-nvim
        pkgs.vimPlugins.telescope-ui-select-nvim
        pkgs.vimPlugins.telescope-fzf-native-nvim
        pkgs.vimPlugins.telescope-manix
        {
          plugin = pkgs.vimPlugins.telescope-nvim;
          type = "lua";
          config = builtins.readFile ./telescope-nvim-config.lua;
        }

        pkgs.vimPlugins.vim-nix

        {
          plugin = pkgs.vimPlugins.vim-auto-save;
          config = /* lua */ "let g:auto_save = 1";
        }

        {
          plugin = pkgs.vimPlugins.gitsigns-nvim;
          type = "lua";
          config = builtins.readFile ./gitsigns-config.lua;
        }

        {
          plugin = pkgs.vimPlugins.comment-nvim;
          type = "lua";
          config = /* lua */ ''
            require('Comment').setup {}
            local ft = require('Comment.ft')
            ft.set('clojure', ';; %s')
          '';
        }

        {
          plugin = pkgs.vimPlugins.lualine-nvim;
          type = "lua";
          config = /* lua */ ''
            require('lualine').setup {
              options = {
                icons_enabled = true,
                theme = lualine_theme or 'auto',
                component_separators = { left = "", right = ""},
                section_separators = { left = "", right = ""},
                disabled_filetypes = {},
                always_divide_middle = true,
              },
              sections = {
                lualine_a = {'mode'},
                lualine_b = {'branch', 'diff', 'diagnostics'},
                lualine_c = {'%f'},
                lualine_x = {'filetype'},
                lualine_y = {'progress'},
                lualine_z = {'location'}
              },
              inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {'filename'},
                lualine_x = {'location'},
                lualine_y = {},
                lualine_z = {}
              },
              tabline = {},
              -- extensions = {'nvim-tree'}
            }
          '';
        }

        {
          plugin = pkgs.vimPlugins.auto-session;
          type = "lua";
          config = /* lua */ ''
            vim.o.sessionoptions="buffers,curdir,folds,help,tabpages,winsize,winpos"
            require('auto-session').setup {
              auto_save_enabled = true,
              auto_restore_enabled = true
            }
          '';
        }

        pkgs.vimPlugins.nvim-web-devicons

        {
          plugin = pkgs.vimPlugins.bufferline-nvim;
          type = "lua";
          config = /* lua */ ''
            local buff = require('bufferline')
            buff.setup {
              options = {
                mode = 'buffers',
                separator_style = 'thin',
                sort_by = 'directory'
              }
            }
            vim.api.nvim_set_hl(0, "BufferlineFill", { link = "BufferlineBackground" })
            vim.keymap.set('n', 'H', '<cmd>BufferLineCyclePrev<cr>')
            vim.keymap.set('n', 'L', '<cmd>BufferLineCycleNext<cr>')
          '';
        }

        pkgs.vimPlugins.suda-vim

        {
          plugin = pkgs.vimPlugins.vim-eunuch;
          type = "lua";
          config = /* lua */ ''
            local delete_eunuch_cmds = function()
              vim.cmd 'delcommand SudoEdit'
              vim.cmd 'delcommand SudoWrite'
            end
            vim.api.nvim_create_autocmd({'VimEnter'}, {
              callback = delete_eunuch_cmds
            })
          '';
        }

        {
          plugin = pkgs.vimPlugins.nvim-colorizer-lua;
          type = "lua";
          config = /* lua */ ''
            require 'colorizer'.setup {
              user_default_options = {
                RGB = true, -- #RGB hex codes
                RRGGBB = true, -- #RRGGBB hex codes
                names = false, -- "Name" codes like Blue or blue
                RRGGBBAA = true, -- #RRGGBBAA hex codes
                AARRGGBB = true, -- 0xAARRGGBB hex codes
                rgb_fn = true, -- CSS rgb() and rgba() functions
                hsl_fn = true, -- CSS hsl() and hsla() functions
                -- Available modes for `mode`: foreground, background,  virtualtext
                mode = "virtualtext", -- Set the display mode.
                -- Available methods are false / true / "normal" / "lsp" / "both"
                -- True is same as normal
                tailwind = false, -- Enable tailwind colors
                -- parsers can contain values used in |user_default_options|
                sass = { enable = false, parsers = { "css" }, }, -- Enable sass colors
                virtualtext = "■",
              },
            }
          '';
        }

        {
          plugin = pkgs.vimPlugins.vim-better-whitespace;
          type = "lua";
          config = /* lua */ ''
            vim.g["better_whitespace_guicolor"] = "${theme.red}"
            vim.g["better_whitespace_filetypes_blacklist"] = {
              "", "diff", "git", "gitcommit", "unite", "qf", "help", "fugitive"
            }
          '';
        }


        {
          plugin = pkgs.vimPlugins.nvim-bqf;
          type = "lua";
          config = /* lua */ ''
            require('bqf').setup {
              auto_enable = true,
              auto_resize_height = true,
              preview = {
                win_height = 20,
                winblend = 0,
              },
            }
          '';
        }

        pkgs.vimPlugins.vim-just

        {
          plugin = nnn-nvim;
          type = "lua";
          config = /* lua */ ''
            local nnn_builtin = require("nnn").builtin
            require("nnn").setup{
              explorer = {
                cmd = "nnn -ouAG",       -- command override (-F1 flag is implied, -a flag is invalid!)
                width = 24,        -- width of the vertical split
                side = "topleft",  -- or "botright", location of the explorer window
                session = "",      -- or "global" / "local" / "shared"
                tabs = true,       -- separate nnn instance per tab
                fullscreen = false, -- whether to fullscreen explorer window when current tab is empty
              },
              picker = {
                cmd = "tmux new-session nnn -ouAGP w",       -- command override (-p flag is implied)
                style = {
                  width = 0.9,     -- percentage relative to terminal size when < 1, absolute otherwise
                  height = 0.8,    -- ^
                  xoffset = 0.5,   -- ^
                  yoffset = 0.5,   -- ^
                  border = "single"-- border decoration for example "rounded"(:h nvim_open_win)
                },
                session = "",      -- or "global" / "local" / "shared"
                tabs = true,       -- separate nnn instance per tab
                fullscreen = false, -- whether to fullscreen picker window when current tab is empty
              },
              auto_open = {
                setup = nil,       -- or "explorer" / "picker", auto open on setup function
                tabpage = nil,     -- or "explorer" / "picker", auto open when opening new tabpage
                empty = false,     -- only auto open on empty buffer
                ft_ignore = {      -- dont auto open for these filetypes
                  "gitcommit",
                }
              },
              auto_close = false,  -- close tabpage/nvim when nnn is last window
              replace_netrw = nil, -- or "explorer" / "picker"
              mappings = {
                { "<C-t>", nnn_builtin.open_in_tab },       -- open file(s) in tab
                { "<C-x>", nnn_builtin.open_in_split },     -- open file(s) in split
                { "<C-v>", nnn_builtin.open_in_vsplit },    -- open file(s) in vertical split
              },       -- table containing mappings, see below
              windownav = {        -- window movement mappings to navigate out of nnn
                left = "<C-h>",
                right = "<C-l>",
                next = "<C-w>w",
                prev = "<C-w>W",
              },
              buflisted = false,   -- whether or not nnn buffers show up in the bufferlist
              quitcd = nil,        -- or "cd" / tcd" / "lcd", command to run on quitcd file if found
              offset = true,      -- whether or not to write position offset to tmpfile(for use in preview-tui)
            }
            vim.keymap.set("n", "<leader>n", "<cmd>NnnPicker %:p:h<cr>")
            vim.keymap.set("n", "<leader>N", "<cmd>NnnPicker<cr>")
          '';
        }

      ] ++ (lib.lists.optionals systemConfig.activities.coding [
        {
          plugin = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
          type = "lua";
          config = /* lua */ ''
            require'nvim-treesitter.configs'.setup {
              -- ensure_installed = "all",
              highlight = {
                enable = true,
              },
              indent = {
                enable = true,
              }
            }
            vim.opt.foldenable = false -- toggle with zi
            vim.opt.foldmethod = 'expr'
            vim.cmd 'set foldexpr=nvim_treesitter#foldexpr()'
            -- This will work in future Neovim versions
            -- https://www.reddit.com/r/neovim/comments/16xz3q9/treesitter_highlighted_folds_are_now_in_neovim
            -- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            -- vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"

            -- Also Nix code will soon have support for embedded language injections with comments
            -- https://github.com/nvim-treesitter/nvim-treesitter/pull/4658
            -- Need version 2023-10-01 or later
          '';
        }

        {
          plugin = pkgs.vimPlugins.nvim-lspconfig;
          type = "lua";
          config = builtins.readFile ./nvim-lspconfig.lua;
        }

        {
          plugin = pkgs.vimPlugins.markdown-preview-nvim;
          config =
            let
              nordTheme = pkgs.writeTextFile {
                name = "markdown-preview-nvim-nord-theme.css";
                text = builtins.readFile ../../misc/markdown-preview-nvim-nord-theme.css;
              };
            in
              /* lua */ ''
              let g:mkdp_highlight_css = "${nordTheme}"
            '';
        }

        {
          plugin = pkgs.vimPlugins.nvim-cmp;
          type = "lua";
          config = builtins.readFile ./nvim-cmp-config.lua;
        }
        pkgs.vimPlugins.lspkind-nvim
        pkgs.vimPlugins.luasnip
        pkgs.vimPlugins.cmp-nvim-lua
        pkgs.vimPlugins.cmp-nvim-lsp

        pkgs.vimPlugins.playground

        {
          plugin = pkgs.vimPlugins.conjure;
          type = "lua";
          config = /* lua */ ''
            vim.g['conjure#mapping#prefix'] = ','
            vim.g['conjure#log#hud#width'] = 1
            vim.g['conjure#log#hud#height'] = 0.6
            vim.g['conjure#client#clojure#nrepl#connection#auto_repl#enabled'] = false
            vim.g['conjure#eval#gsubs'] = {
              ['do-comment'] = {'^%(comment[%s%c]', '(do '}
            }
            vim.g['conjure#eval#result_register'] = '*'
            vim.g['conjure#mapping#doc_word'] = '<localleader>K'
            vim.g['conjure#client_on_load'] = false
          '';
        }

      ]);
  };
}
