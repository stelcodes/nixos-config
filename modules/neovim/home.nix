{ pkgs, theme, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraLuaConfig = builtins.readFile ./base.lua;
    extraPackages = [
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


        stel-telescope-file-browser-nvim = pkgs.vimUtils.buildVimPlugin {
          pname = "stel-telescope-file-browser-nvim";
          version = "1.0";
          src = pkgs.fetchFromGitHub {
            owner = "stelcodes";
            repo = "telescope-file-browser.nvim";
            rev = "6ef20dd9e03a30bd116d872aefbceb277b6a3855";
            sha256 = "MRoCpqfyVB3G7XNYzQYlIR+Guip2dhuttfIY1Wol76s=";
          };
        };
      in
      [
        # Theme plugin should go first because it sets local vars like lualine_theme
        theme.neovimPlugin

        pkgs.vimPlugins.vim-fugitive
        {
          plugin = pkgs.vimPlugins.conjure;
          type = "lua";
          config = ''
            vim.g['conjure#mapping#prefix'] = ','
            vim.g['conjure#log#hud#width'] = 1
            vim.g['conjure#log#hud#height'] = 0.6
            vim.g['conjure#client#clojure#nrepl#connection#auto_repl#enabled'] = false
            vim.g['conjure#eval#gsubs'] = {
              ['do-comment'] = {'^%(comment[%s%c]', '(do '}
            }
            vim.g['conjure#eval#result_register'] = '*'
          '';
        }
        {
          plugin = stel-paredit;
          type = "lua";
          config = ''
            vim.g['paredit_smartjump'] = 1
            vim.g['paredit_matchlines'] = 500
          '';
        }
        pkgs.vimPlugins.plenary-nvim
        stel-telescope-file-browser-nvim
        pkgs.vimPlugins.telescope-ui-select-nvim
        {
          plugin = pkgs.vimPlugins.telescope-nvim;
          type = "lua";
          config = builtins.readFile ./telescope-nvim-config.lua;
        }

        pkgs.vimPlugins.vim-nix

        {
          plugin = pkgs.vimPlugins.vim-auto-save;
          config = "let g:auto_save = 1";
        }

        {
          plugin = pkgs.vimPlugins.gitsigns-nvim;
          type = "lua";
          config = builtins.readFile ./gitsigns-config.lua;
        }

        {
          plugin = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
          type = "lua";
          config = ''
            require'nvim-treesitter.configs'.setup {
              -- ensure_installed = "all",
              highlight = {
                enable = true,
              },
              indent = {
                enable = true,
              }
            }
            vim.opt.foldlevelstart = 99
            vim.opt.foldenable = false
            vim.opt.foldmethod = 'expr'
            vim.cmd 'set foldexpr=nvim_treesitter#foldexpr()'
          '';
        }

        {
          plugin = pkgs.vimPlugins.comment-nvim;
          type = "lua";
          config = ''
            require('Comment').setup {}
            local ft = require('Comment.ft')
            ft.set('clojure', ';; %s')
          '';
        }

        {
          plugin = pkgs.vimPlugins.lualine-nvim;
          type = "lua";
          config = ''
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
          config = ''
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
          config = ''
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
          config = ''
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
          plugin = pkgs.vimPlugins.nvim-lspconfig;
          type = "lua";
          config = builtins.readFile ./nvim-lspconfig.lua;
        }

        {
          plugin = pkgs.vimPlugins.nvim-colorizer-lua;
          type = "lua";
          config = ''
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
          plugin = pkgs.vimPlugins.markdown-preview-nvim;
          config =
            let
              nordTheme = pkgs.writeTextFile {
                name = "markdown-preview-nvim-nord-theme.css";
                text = builtins.readFile ../../misc/markdown-preview-nvim-nord-theme.css;
              }; in
            ''
              let g:mkdp_highlight_css = "${nordTheme}"
            '';
        }

        {
          plugin = pkgs.vimPlugins.vim-better-whitespace;
          type = "lua";
          config = ''
            vim.g["better_whitespace_guicolor"] = "${theme.red}"
            vim.g["better_whitespace_filetypes_blacklist"] = {
              "", "diff", "git", "gitcommit", "unite", "qf", "help", "fugitive"
            }
          '';
        }

        pkgs.vimPlugins.playground
      ];
  };
}
