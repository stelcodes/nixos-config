{ pkgs, lib, config, systemConfig, ... }:
let
  theme = systemConfig.theme.set;
  plugins = pkgs.unstable.vimPlugins;
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

      in
      [
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

        plugins.vim-nix

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
            local f = function()
              require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
            end
            local pre_hook = pcall(f) or nil
            require('Comment').setup {
              pre_hook = pre_hook,
            }
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
            vim.o.sessionoptions="buffers,curdir,folds,help,tabpages,winsize,winpos"
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

        plugins.suda-vim

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
          plugin = nnn-nvim;
          type = "lua";
          config =
            let
              session-command = pkgs.writers.writeBash "nnn-nvim-tmux-session" ''
                # Make sure to pass along the nnn args added by the plugin
                nnn -ouaAGP t $@
                tmux detach-client
              '';
            in
              /* lua */ ''
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
                  cmd = "tmux new-session -- ${session-command}", -- command override (-p flag is implied)
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

              local nnn_buffer_dir = function()
                vim.fn.setreg("/", "")
                if vim.bo.filetype == "fugitive" then
                  vim.cmd "NnnPicker"
                else
                  vim.cmd "NnnPicker %:p:h"
                end
              end

              local nnn_working_dir = function()
                vim.fn.setreg("/", "")
                vim.cmd "NnnPicker"
              end

              vim.keymap.set("n", "<leader>n", nnn_buffer_dir)
              vim.keymap.set("n", "<leader>N", nnn_working_dir)
            '';
        }

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

      ] ++ (lib.lists.optionals systemConfig.activities.coding [

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

        {
          # TODO: Use nixpkgs version when development slows down
          plugin = pkgs.vimUtils.buildVimPlugin {
            pname = "obsidian.nvim";
            version = "3.6.0";
            src = pkgs.fetchFromGitHub {
              owner = "epwalsh";
              repo = "obsidian.nvim";
              rev = "b77e4c15ebc7e8de0633fed7270099e3978143d9";
              hash = "sha256-LGGy+nGnLUjBQN19WpXcORWw7A7W7xv6uM0zP18T6QY=";
            };
            # dependencies = [ plugins.plenary-nvim ];
          };
          type = "lua";
          config = /* lua */ ''
            local obs = require("obsidian")
            obs.setup {
              workspaces = {
                { name = "journal", path = "~/sync/vaults/journal" }
              },
              daily_notes = {
                folder = "daily",
                date_format = "%Y-%m-%d",
                template = nil
              },
              new_notes_location = "notes_subdir",
              mappings = {
                ["<leader>on"] = {
                  action = function() vim.cmd "ObsidianNew" end,
                  opts = { buffer = true },
                },
                ["<leader>oc"] = {
                  action = obs.util.toggle_checkbox,
                  opts = { buffer = true },
                },
                ["<leader>od"] = {
                  action = function() vim.cmd "ObsidianToday" end,
                  opts = { buffer = true },
                },
                ["<leader>ot"] = {
                  action = function() vim.cmd "ObsidianTags" end,
                  opts = { buffer = true },
                },
                ["<leader>ob"] = {
                  action = function() vim.cmd "ObsidianBacklinks" end,
                  opts = { buffer = true },
                },
                ["<leader>oq"] = {
                  action = function() vim.cmd "ObsidianQuickSwitch" end,
                  opts = { buffer = true },
                },
                ["<leader>oo"] = {
                  action = function() vim.cmd "ObsidianOpen" end,
                  opts = { buffer = true },
                },
                ["<leader>or"] = {
                  action = function() vim.cmd "ObsidianRename" end,
                  opts = { buffer = true },
                },
              },
            }
          '';
        }

        {
          plugin = pkgs.vimUtils.buildVimPlugin {
            pname = "kanban-nvim";
            version = "unstable-2023-12-08";
            #src = pkgs.fetchFromGitHub {
            #  owner = "arakkkkk";
            #  repo = "kanban.nvim";
            #  rev = "640962c9b06709e4701cf2e063b43a3fd89db39c";
            #  hash = "sha256-QuRAp9CZYFyXlSo+1oZ8Ti1MHaHgN/8ixuMjTScz3G8=";
            #};
          };
          type = "lua";
          config = /* lua */ ''
            require("kanban").setup()
            vim.keymap.set('n', '<leader>ko', '<cmd>KanbanOpen telescope<cr>')
            vim.keymap.set('n', '<leader>kn', '<cmd>KanbanCreate')
          '';
        }

      ]);
  };
}
