{ pkgs, ... }: {
  config = let
    # unstable = import <nixos-unstable> { };
  in {
    programs.neovim.enable = true;
    # programs.neovim.package = neovim-unwrapped;
    programs.neovim.defaultEditor = true;
    # programs.neovim.viAlias = true;
    # programs.neovim.vimAlias = true;
    programs.neovim.runtime = {
      "filetype.vim".source = ./filetype.vim;
    };
    programs.neovim.configure.customRC =
      builtins.readFile ./extra-config.vim;
    programs.neovim.configure.packages.myVimPackage = let
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
    in with pkgs.vimPlugins; {
      start = [
        nerdtree
        vim-obsession
        vim-commentary
        vim-dispatch
        vim-projectionist
        vim-eunuch
        vim-fugitive
        vim-sensible
        vim-nix
        lightline-vim
        conjure
        vim-fish
        vim-css-color
        tabular
        vim-gitgutter
        vim-auto-save
        ale
        nord-vim
        stel-paredit
        plenary-nvim
        telescope-nvim
        {
          plugin = "telescope-nvim";
          config = ''
            packadd! telescope-nvim
            lua <<EOF
            ${builtins.readFile ./telescope-nvim.lua}
            EOF
          '';
        }
        telescope-ui-select-nvim
        telescope-file-browser-nvim
        nvim-lspconfig
        markdown-preview-nvim
        vim-better-whitespace
        lualine-nvim
        nvim-web-devicons
        gitsigns-nvim
      ];
    };
  };
}
