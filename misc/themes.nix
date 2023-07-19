{ pkgs, ... }: {

  # https://github.com/tinted-theming/base16-schemes
  # s/\v(\w+): "(\w+)"/\1 = "#\2";

  nord = rec {
    name = "Nord";
    slug = "nord";

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

    gtkTheme = "Nordic";
    gtkThemePackage = pkgs.nordic;
    gtkIconTheme = "Nordzy";
    gtkIconThemePackage = pkgs.nordzy-icon-theme;

    neovimColorscheme = "nordic";
    lualineTheme = "nord";
    markdownPreviewCSS = builtins.readFile ./markdown-preview-nvim-nord-theme.css;

  };

  everforest = rec {
    name = "Everforest";
    slug = "everforest";

    base00 = "#2f383e";
    base01 = "#374247";
    base02 = "#4a555b";
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

    black = "#222730";

    # gtkTheme = "Nordic";
    # gtkThemePackage = pkgs.nordic;
    # gtkIconTheme = "Nordzy";
    # gtkIconThemePackage = pkgs.nordzy-icon-theme;
    #
    # neovimColorscheme = "nordic";
    # lualineTheme = "nord";
  };
}
