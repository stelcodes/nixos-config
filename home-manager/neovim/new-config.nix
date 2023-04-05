pkgs: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
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
      {
        plugin = hydropump-nvim;
        type = "lua";
        config = ''
         vim.cmd 'colorscheme hydropump'
        '';
      }
      vim-fugitive
      {
        plugin = conjure;
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
      plenary-nvim
      stel-telescope-file-browser-nvim
      telescope-ui-select-nvim
      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ./telescope-nvim-config.lua;
      }

      # { plugin = foo;
      #   type = "lua"
      #  config = ''
      #  '';
      #  }

    ];
  };
}
