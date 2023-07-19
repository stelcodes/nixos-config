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

    xdg.configFile."fish/themes/base16.theme" = ''
      fish_color_autosuggestion ${bg3}
      fish_color_cancel -r
      fish_color_command ${blue}
      fish_color_comment ${bg2}
      # fish_color_cwd green
      # fish_color_cwd_root red
      fish_color_end ${bg3}
      fish_color_error ${red}
      # fish_color_escape 00a6b2
      fish_color_history_current --bold
      # fish_color_host normal
      # fish_color_host_remote yellow
      fish_color_keyword ${blue}
      # fish_color_match --background=brblue
      fish_color_normal normal
      fish_color_operator ${yellow}
      fish_color_option ${cyan}
      fish_color_param ${cyan}
      fish_color_quote ${green}
      fish_color_redirection ${magenta}
      # fish_color_search_match 'bryellow'  '--background=brblack'
      fish_color_selection 'white'  '--bold'  '--background=brblack'
      # fish_color_status red
      # fish_color_user brgreen
      fish_color_valid_path --underline
      # fish_pager_color_background
      # fish_pager_color_completion normal
      # fish_pager_color_description 'B3A06D'  'yellow'
      # fish_pager_color_prefix 'normal'  '--bold'  '--underline'
      # fish_pager_color_progress 'brwhite'  '--background=cyan'
      # fish_pager_color_secondary_background
      # fish_pager_color_secondary_completion
      # fish_pager_color_secondary_description
      # fish_pager_color_secondary_prefix
      # fish_pager_color_selected_background --background=brblack
      # fish_pager_color_selected_completion
      # fish_pager_color_selected_description
      # fish_pager_color_selected_prefix
    '';

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

    black = "#222730";

    gtkTheme = "Nordic";
    gtkThemePackage = pkgs.nordic;
    gtkIconTheme = "Nordzy";
    gtkIconThemePackage = pkgs.nordzy-icon-theme;

    neovimColorscheme = "nordic";
    lualineTheme = "nord";
  };
}

