pkgs: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraLuaConfig = builtins.readFile ./base.lua;
    plugins = let
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
          repo = "telescope-file-browser-nvim";
          rev = "6ef20dd9e03a30bd116d872aefbceb277b6a3855";
          sha256 = "MRoCpqfyVB3G7XNYzQYlIR+Guip2dhuttfIY1Wol76s=";
        };
      };
    in with pkgs.vimPlugins; [

      # {
      #  plugin = hydropump-nvim;
      #  config = "colorscheme hydropump";
      # }
      
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

      {
        plugin = pkgs.vimPlugins.nord-vim;
        config = "colorscheme nord";
      }

      vim-nix

      {
        plugin = pkgs.vimPlugins.vim-auto-save;
        config = "let g:auto_save = 1";
      }

      {
        plugin = pkgs.vimPlugins.gitsigns-nvim;
        type = "lua";
        config = ''
          local gs = require('gitsigns')
          -- the :w is so fugitive will pick up the staging changes
          vim.keymap.set({'n','v'}, '<leader>gs', gs.stage_hunk)
          vim.keymap.set('n', '<leader>gu', gs.undo_stage_hunk)
          vim.keymap.set({'n', 'v'}, '<leader>gr', gs.reset_hunk)
          vim.keymap.set('n', '<leader>gR', gs.reset_buffer)
          vim.keymap.set('n', '<leader>gp', gs.prev_hunk)
          vim.keymap.set('n', '<leader>gn', gs.next_hunk)
          vim.keymap.set('n', '<leader>gb', function() gs.blame_line{full=true} end)
          vim.keymap.set('n', '<leader>gS', gs.stage_buffer)
          vim.keymap.set('n', '<leader>gU', gs.reset_buffer_index)
          vim.keymap.set('n', '<leader>gq', gs.setqflist)
        '';
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
      config = '';
        require('lualine').setup {
          options = {
            icons_enabled = true,
            theme = 'nord',
            component_separators = { left = ''', right = '''},
            section_separators = { left = ''', right = '''},
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
        vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
        require('auto-session').setup {
          auto_restore_enabled = false
        }
      '';
    }

  ];
};
}
