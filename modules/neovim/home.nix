{ pkgs, lib, config, inputs, ... }:
let
  theme = config.theme.set;
  plugins = pkgs.unstable.vimPlugins;
in
{
  programs.neovim = {
    enable = true;
    package = pkgs.unstable.neovim-unwrapped;
    defaultEditor = true;
    withPython3 = false;
    withNodeJs = false;
    withRuby = false;
    extraLuaConfig = builtins.readFile ./base.lua;
    extraPackages = lib.lists.optionals config.activities.coding [
      pkgs.clojure-lsp
      pkgs.nil
      pkgs.nixpkgs-fmt
      pkgs.pyright
      pkgs.nodePackages.typescript-language-server
      pkgs.rust-analyzer
      pkgs.java-language-server
      pkgs.lua-language-server
      pkgs.vscode-langservers-extracted
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

        resize-nvim = pkgs.vimUtils.buildVimPlugin {
          pname = "resize-nvim";
          version = "unstable-2024-01-16";
          src = pkgs.fetchFromGitHub {
            owner = "stelcodes";
            repo = "resize.nvim";
            rev = "a0b28847f69d234de933685503df84a88e7ae514";
            sha256 = "jGEVE9gfK4EirGDOFzSNXn60X+IldKASVoTD4/p7MBM=";
          };
        };

        nvim-origami = pkgs.vimUtils.buildVimPlugin {
          pname = "nvim-origami";
          version = "unstable";
          src = inputs.nvim-origami;
        };

      in
      [

        {
          plugin = nvim-origami;
          type = "lua";
          config = /* lua */ ''
            require("origami").setup({
              hOnlyOpensOnFirstColumn = true
            })
          '';
        }

        {
          plugin = plugins.yazi-nvim;
          type = "lua";
          config = /* lua */ ''
            local y = require('yazi')
            y.setup()
            vim.keymap.set('n', '<leader>y', y.yazi)
          '';
        }

        # Theme plugin should go first because it sets local vars like lualine_theme
        theme.neovimPlugin

        {
          plugin = plugins.vim-fugitive;
          type = "lua";
          config = /* lua */ ''
            local toggle_fugitive = function()
              if vim.bo.filetype == "fugitive" then
                vim.cmd "wincmd q"
              else
                vim.cmd "Git"
                vim.cmd "wincmd H"
                vim.cmd "vertical resize 70"
              end
            end
            vim.keymap.set('n', '<c-g>', toggle_fugitive)
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

        plugins.plenary-nvim
        plugins.telescope-file-browser-nvim
        plugins.telescope-ui-select-nvim
        plugins.telescope-fzf-native-nvim
        plugins.telescope-manix
        {
          plugin = plugins.telescope-nvim;
          type = "lua";
          config = builtins.readFile ./telescope-nvim-config.lua;
        }

        {
          plugin = plugins.vim-auto-save;
          config = /* vim */ "let g:auto_save = 1";
        }

        {
          plugin = plugins.gitsigns-nvim;
          type = "lua";
          config = builtins.readFile ./gitsigns-config.lua;
        }

        {
          plugin = plugins.comment-nvim;
          type = "lua";
          config = /* lua */ ''
            local opts = {}
            -- Don't rely on this plugin or treesitter being present
            local success, pre_hook = pcall(function()
              require('ts_context_commentstring').setup {
                enable_autocmd = false,
              }
              return require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
            end)
            if success then
              opts.pre_hook = pre_hook
            end
            require('Comment').setup(opts)
            local ft = require('Comment.ft')
            ft.set('clojure', ';; %s')
          '';
        }

        {
          plugin = plugins.lualine-nvim;
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
          plugin = plugins.auto-session;
          type = "lua";
          config = /* lua */ ''
            vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
            require('auto-session').setup {
              auto_save_enabled = true,
              auto_restore_enabled = true
            }
          '';
        }

        plugins.nvim-web-devicons

        {
          plugin = plugins.bufferline-nvim;
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

        plugins.vim-suda

        {
          plugin = plugins.vim-eunuch;
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
          plugin = plugins.nvim-colorizer-lua;
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
          plugin = plugins.vim-better-whitespace;
          type = "lua";
          config = /* lua */ ''
            vim.g["better_whitespace_guicolor"] = "${theme.red}"
            vim.g["better_whitespace_filetypes_blacklist"] = {
              "", "diff", "git", "gitcommit", "unite", "qf", "help", "fugitive"
            }
          '';
        }


        {
          plugin = plugins.nvim-bqf;
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

        plugins.vim-just

        {
          plugin = resize-nvim;
          type = "lua";
          config = /* lua */ ''
            local r = require('resize')
            vim.keymap.set('n', '<c-left>', function() r.ResizeLeft(1) end)
            vim.keymap.set('n', '<c-right>', function() r.ResizeRight(1) end)
            vim.keymap.set('n', '<c-up>', function() r.ResizeUp(1) end)
            vim.keymap.set('n', '<c-down>', function() r.ResizeDown(1) end)
          '';
        }

        {
          plugin = pkgs.vimUtils.buildVimPlugin {
            pname = "nvim-listchars";
            version = "unstable-2024-02-24";
            src = pkgs.fetchFromGitHub {
              owner = "0xfraso";
              repo = "nvim-listchars";
              rev = "40b05e8375af11253434376154a9e6b3e9400747";
              hash = "sha256-SQPe1c3EzVdqpU41FqwR2owfstDqSLjNlrpJuaLZXNE=";
            };
          };
          type = "lua";
          config = /* lua */ ''
            vim.opt.list = true
            require("nvim-listchars").setup {
              save_state = true,
              notifications = false,
              listchars = {
                -- space = ' ',
                eol = "↲",
                tab = "» ",
                trail = '·',
                extends = '<',
                precedes = '>',
                conceal = '┊',
                nbsp = '␣',
              },
            }
            vim.cmd 'ListcharsDarkenColors'
            vim.keymap.set('n', '<c-.>', '<cmd>ListcharsToggle<cr>')
          '';
        }

      ] ++ (lib.lists.optionals config.activities.coding [

        plugins.nvim-ts-context-commentstring # For accurate comments
        {
          plugin = plugins.nvim-treesitter.withAllGrammars;
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
            vim.opt.foldlevel = 99
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
          plugin = plugins.nvim-lspconfig;
          type = "lua";
          config = builtins.readFile ./nvim-lspconfig.lua;
        }

        {
          plugin = plugins.markdown-preview-nvim;
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
          plugin = plugins.nvim-cmp;
          type = "lua";
          config = builtins.readFile ./nvim-cmp-config.lua;
        }
        plugins.lspkind-nvim
        plugins.luasnip
        plugins.cmp-nvim-lua
        plugins.cmp-nvim-lsp

        plugins.playground

        {
          plugin = plugins.conjure;
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
