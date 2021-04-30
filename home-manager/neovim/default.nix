pkgs: {
  xdg.configFile = { "nvim/filetype.vim".source = ./filetype.vim; };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    plugins = let

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

      suda-vim = pkgs.vimUtils.buildVimPlugin {
        pname = "suda.vim";
        version = "0.2.0";
        src = pkgs.fetchFromGitHub {
          owner = "lambdalisue";
          repo = "suda.vim";
          rev = "45f88d4f0699c054af775b82c87b93b439da0a22";
          sha256 = "0apf28b569qz4vik23jl0swka37qwmbxxiybfrksy7i1yaq6d38g";
        };
      };
    in [
      pkgs.vimPlugins.nerdtree
      pkgs.vimPlugins.vim-obsession
      pkgs.vimPlugins.vim-commentary
      pkgs.vimPlugins.vim-dispatch
      pkgs.vimPlugins.vim-projectionist
      pkgs.vimPlugins.vim-eunuch
      pkgs.vimPlugins.vim-fugitive
      pkgs.vimPlugins.vim-sensible
      pkgs.vimPlugins.vim-nix
      pkgs.vimPlugins.lightline-vim
      pkgs.vimPlugins.conjure
      pkgs.vimPlugins.vim-fish
      pkgs.vimPlugins.vim-css-color
      pkgs.vimPlugins.tabular
      pkgs.vimPlugins.vim-gitgutter
      # {
      #   plugin = suda-vim;
      #   config = "command! W SudaWrite";
      # }
      {
        plugin = pkgs.vimPlugins.vim-auto-save;
        config = "let g:auto_save = 1";
      }
      {
        plugin = pkgs.vimPlugins.ale;
        config = "let g:ale_linters = {'clojure': ['clj-kondo']}";
      }
      {
        plugin = pkgs.vimPlugins.nord-vim;
        config = "colorscheme nord";
      }
      {
        plugin = stel-paredit;
        config = "let g:paredit_smartjump=1";
      }
      # Waiting on markdown plugin to get added to nixpkgs
      # {
      #   plugin = markdown-preview;
      #   config = ''
      #     '';
      # }
    ];
    extraConfig = (builtins.readFile ./extra-config.vim) + ''

      set shell=${pkgs.zsh}/bin/zsh'';
  };
}
