{ pkgs, ... }: {

  # https://github.com/tinted-theming/base16-schemes
  # https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
  # s/\v(\w+): "(\w+)"/\1 = "#\2";

  nord = rec {
    name = "nord";

    base00 = "#2E3440";
    base01 = "#3B4252";
    base02 = "#434C5E";
    base03 = "#4C566A";
    base04 = "#D8DEE9";
    base05 = "#E5E9F0";
    base06 = "#ECEFF4";
    base07 = "#8FBCBB";
    base08 = "#BF616A";
    base09 = "#D08770";
    base0A = "#EBCB8B";
    base0B = "#A3BE8C";
    base0C = "#88C0D0";
    base0D = "#81A1C1";
    base0E = "#B48EAD";
    base0F = "#5E81AC";

    bg = base00;
    bg1 = base01;
    bg2 = base02;
    bg3 = base03;
    bg4 = base04;
    fg = base05;
    fg1 = base06;
    alt1 = base07;
    red = base08;
    orange = base09;
    yellow = base0A;
    green = base0B;
    cyan = base0C;
    blue = base0D;
    magenta = base0E;
    alt2 = base0F;

    bgx = builtins.substring 1 6 bg;
    bg1x = builtins.substring 1 6 bg1;
    bg2x = builtins.substring 1 6 bg2;
    bg3x = builtins.substring 1 6 bg3;
    bg4x = builtins.substring 1 6 bg4;
    fgx = builtins.substring 1 6 fg;
    fg1x = builtins.substring 1 6 fg1;
    alt1x = builtins.substring 1 6 alt1;
    redx = builtins.substring 1 6 red;
    orangex = builtins.substring 1 6 orange;
    yellowx = builtins.substring 1 6 yellow;
    greenx = builtins.substring 1 6 green;
    cyanx = builtins.substring 1 6 cyan;
    bluex = builtins.substring 1 6 blue;
    magentax = builtins.substring 1 6 magenta;
    alt2x = builtins.substring 1 6 alt2;

    black = "#222730";
    # swayBorder = "#616e88";

    gtkThemeName = "Nordic";
    gtkThemePackage = pkgs.nordic;
    iconThemeName = "Nordzy";
    iconThemePackage = pkgs.nordzy-icon-theme;
    cursorThemeName = "Nordzy-cursors";
    cursorThemePackage = pkgs.nordzy-cursor-theme;

    neovimPlugin = {
      plugin = pkgs.vimPlugins.nordic-nvim;
      type = "lua";
      config = ''
        require('nordic').colorscheme {
          underline_option = 'none',
          italic = false,
          italic_comments = false,
          minimal_mode = true,
          alternate_backgrounds = false
        }
        vim.cmd 'colorscheme nordic'

        -- switch lualine nord theme normal bg colors
        local lualine_theme = require('lualine.themes.nord')
        local tmp = lualine_theme.normal.b.bg
        lualine_theme.normal.b.bg = lualine_theme.normal.c.bg
        lualine_theme.normal.c.bg = tmp
      '';
    };

    markdownPreviewCSS = builtins.readFile ./markdown-preview-nvim-nord-theme.css;

    tmuxPrimary = cyan;
    tmuxSecondary = yellow;

    vscode = {
      extension = pkgs.vscode-extensions.arcticicestudio.nord-visual-studio-code;
      themeName = "Nord";
    };

    btop = "nord";
  };

  everforest = rec {
    name = "everforest";

    base00 = "#272e33";
    # original base00 = "#2f383e";
    base01 = "#2e383c";
    # original base01 = "#374247";
    base02 = "#414b50";
    # original base02 = "#4a555b";
    base03 = "#859289";
    base04 = "#9da9a0";
    base05 = "#d3c6aa";
    base06 = "#e4e1cd";
    base07 = "#fdf6e3";
    base08 = "#7fbbb3";
    base09 = "#d699b6";
    base0A = "#dbbc7f";
    base0B = "#83c092";
    base0C = "#e69875";
    base0D = "#a7c080";
    base0E = "#e67e80";
    base0F = "#eaedc8";

    bg = base00;
    bg1 = base01;
    bg2 = base02;
    bg3 = base03;
    bg4 = base04;
    fg = base05;
    fg1 = base06;
    alt1 = base07;
    red = base0E;
    orange = base0C;
    yellow = base0A;
    green = base0D;
    cyan = base0B;
    blue = base08;
    magenta = base09;
    alt2 = base0F;

    bgx = builtins.substring 1 6 bg;
    bg1x = builtins.substring 1 6 bg1;
    bg2x = builtins.substring 1 6 bg2;
    bg3x = builtins.substring 1 6 bg3;
    bg4x = builtins.substring 1 6 bg4;
    fgx = builtins.substring 1 6 fg;
    fg1x = builtins.substring 1 6 fg1;
    alt1x = builtins.substring 1 6 alt1;
    redx = builtins.substring 1 6 red;
    orangex = builtins.substring 1 6 orange;
    yellowx = builtins.substring 1 6 yellow;
    greenx = builtins.substring 1 6 green;
    cyanx = builtins.substring 1 6 cyan;
    bluex = builtins.substring 1 6 blue;
    magentax = builtins.substring 1 6 magenta;
    alt2x = builtins.substring 1 6 alt2;

    black = "#15191c";

    gtkThemeName = "Everforest-Dark-BL";
    gtkThemePackage = pkgs.callPackage ../packages/everforest-gtk-theme.nix { };
    iconThemeName = "Everforest-Dark";
    iconThemePackage = gtkThemePackage;
    cursorThemeName = "Nordzy-cursors";
    cursorThemePackage = pkgs.nordzy-cursor-theme;

    neovimPlugin = {
      plugin = pkgs.vimPlugins.everforest;
      type = "lua";
      config = ''
        vim.g["everforest_background"] = "hard"
        vim.g["everforest_better_performance"] = 0
        vim.cmd 'colorscheme everforest'
        local lualine_theme = require('lualine.themes.everforest')
      '';
    };

    tmuxPrimary = green;
    tmuxSecondary = red;

    vscode = {
      extension = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "everforest";
          publisher = "sainnhe";
          version = "0.3.0";
          sha256 = "sha256-nZirzVvM160ZTpBLTimL2X35sIGy5j2LQOok7a2Yc7U=";
        };
      };
      themeName = "Everforest Dark";
    };

    btop = "everforest-dark-hard";

    wallpaper = pkgs.fetchurl {
      url = "https://private-user-images.githubusercontent.com/22163194/287509006-b4773ed8-259d-4938-a26b-a2672a97509a.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTEiLCJleHAiOjE3MDE1OTY4OTgsIm5iZiI6MTcwMTU5NjU5OCwicGF0aCI6Ii8yMjE2MzE5NC8yODc1MDkwMDYtYjQ3NzNlZDgtMjU5ZC00OTM4LWEyNmItYTI2NzJhOTc1MDlhLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFJV05KWUFYNENTVkVINTNBJTJGMjAyMzEyMDMlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjMxMjAzVDA5NDMxOFomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTEwNzUyMDI5MjRjMGZlNTRkZmU3ZGM0ZmI3M2E0MDA5NTZhNWNlNjU5NzcwM2FjMTM2ZGU0ODMyZTNiYjVhNmUmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0JmFjdG9yX2lkPTAma2V5X2lkPTAmcmVwb19pZD0wIn0.k__xcgcL0o21KsxicQYBQvDKK5ykOj0NYic4ZbjJ0rU";
      sha256 = "vz2njcQzAhQ894KDPe1mbK07LdDfRbd8MNyQHTe9gTE=";
    };
  };

  rose-pine = rec {

    name = "rose-pine";

    base00 = "#191724";
    base01 = "#1f1d2e";
    base02 = "#26233a";
    base03 = "#6e6a86";
    base04 = "#908caa";
    base05 = "#e0def4";
    base06 = "#e0def4";
    base07 = "#524f67";
    base08 = "#eb6f92";
    base09 = "#f6c177";
    base0A = "#ebbcba";
    base0B = "#31748f";
    base0C = "#9ccfd8";
    base0D = "#c4a7e7";
    base0E = "#f6c177";
    base0F = "#524f67";

    bg = base00;
    bg1 = base01;
    bg2 = base02;
    bg3 = base03;
    bg4 = base04;
    fg = base05;
    fg1 = base06;
    alt1 = base07;
    red = base08;
    yellow = base09;
    green = base0A;
    blue = base0B;
    cyan = base0C;
    magenta = base0D;
    orange = base0E;
    alt2 = base0F;

    bgx = builtins.substring 1 6 bg;
    bg1x = builtins.substring 1 6 bg1;
    bg2x = builtins.substring 1 6 bg2;
    bg3x = builtins.substring 1 6 bg3;
    bg4x = builtins.substring 1 6 bg4;
    fgx = builtins.substring 1 6 fg;
    fg1x = builtins.substring 1 6 fg1;
    alt1x = builtins.substring 1 6 alt1;
    redx = builtins.substring 1 6 red;
    orangex = builtins.substring 1 6 orange;
    yellowx = builtins.substring 1 6 yellow;
    greenx = builtins.substring 1 6 green;
    cyanx = builtins.substring 1 6 cyan;
    bluex = builtins.substring 1 6 blue;
    magentax = builtins.substring 1 6 magenta;
    alt2x = builtins.substring 1 6 alt2;

    black = "#222730";
    # swayBorder = "#616e88";

    gtkThemeName = "RosePine-Main-BL";
    gtkThemePackage = pkgs.callPackage ../packages/rose-pine-gtk-theme.nix { };
    iconThemeName = "Rose-Pine";
    iconThemePackage = gtkThemePackage;
    cursorThemeName = "Nordzy-cursors";
    cursorThemePackage = pkgs.nordzy-cursor-theme;

    neovimPlugin = {
      plugin = pkgs.vimPlugins.rose-pine;
      type = "lua";
      config = ''
        require('rose-pine').setup {
          variant = 'main',
        }
        vim.cmd 'colorscheme rose-pine'
        local lualine_theme = require('lualine.themes.rose-pine')
      '';
    };

    # markdownPreviewCSS = builtins.readFile ./markdown-preview-nvim-nord-theme.css;

    tmuxPrimary = green;
    tmuxSecondary = cyan;

    btop = "tokyo-storm";

  };
}
