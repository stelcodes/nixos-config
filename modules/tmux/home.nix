{ pkgs, ... }: {
  # These packages are needed for tmux-yank to work on remote tmux instances (Xserver and wayland support)
  home.packages = [ pkgs.xsel pkgs.wl-clipboard ];
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    keyMode = "vi";
    newSession = true;
    shell = "${pkgs.fish}/bin/fish";
    prefix = "M-a";
    # Set to "tmux-256color" normally, but theres this macOS bug https://git.io/JtLls
    terminal = "screen-256color";
    extraConfig =
      let
        continuumSaveScript =
          "${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/scripts/continuum_save.sh";
      in
      ''
        # set -ga terminal-overrides ',alacritty:Tc'
        # set -as terminal-overrides ',xterm*:sitm=\E[3m'

        # https://is.gd/8VKFEY
        set -g focus-events on

        # Custom Keybindings
        bind -n M-h previous-window
        bind -n M-l next-window
        bind -n M-H select-pane -L
        bind -n M-L select-pane -R
        bind -n M-J select-pane -D
        bind -n M-K select-pane -U
        bind -n M-Q kill-pane
        # Only really need to detach when using linux console
        # bind -n M-d detach
        bind -n M-f new-window -ac "#{pane_current_path}"
        bind -n M-s choose-tree -s
        bind -n M-c copy-mode
        bind -n M-r command-prompt 'rename-session %%'
        bind -n M-n command-prompt 'new-session'
        bind -n M-R source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

        # Fixes tmux escape input lag, see https://git.io/JtIsn
        set -sg escape-time 10

        # Update environment
        set -g update-environment "PATH"

        # set -g status-style fg=white,bg=default
        # set -g status-justify left
        # set -g status-left ""
        # setting status right makes continuum fail! Apparently it uses the status to save itself? Crazy. https://git.io/JOXd13
        # set -g status-right "#[fg=yellow,bg=default][#S] #[fg=default,bg=default]in #[fg=green,bg=default]#h#(${continuumSaveScript})"

        # From nord tmux plugin
        set -g status-interval 1
        set -g status on
        set -g status-justify left
        set -g status-style bg=black,fg=white
        set -g pane-border-style bg=default,fg=brightblack
        set -g pane-active-border-style bg=default,fg=blue
        set -g display-panes-colour black
        set -g display-panes-active-colour brightblack
        setw -g clock-mode-colour cyan
        set -g message-style bg=brightblack,fg=cyan
        set -g message-command-style bg=brightblack,fg=cyan
        set -g status-left "#[fg=black,bg=cyan,bold] #S "
        set -g status-right "#{prefix_highlight}#[fg=white,bg=brightblack] %Y-%m-%d | %I:%M %p #[fg=black,bg=cyan,bold] #H "
        set -g @prefix_highlight_output_prefix " "
        set -g @prefix_highlight_output_suffix " "
        set -g @prefix_highlight_fg black
        set -g @prefix_highlight_bg blue
        set -g @prefix_highlight_copy_mode_attr "fg=brightcyan,bg=black,bold"
        set -g window-status-format "#[fg=white,bg=black] #I #W #F "
        set -g window-status-current-format "#[fg=white,bg=brightblack] #I #W #F "
        set -g window-status-separator ""
      '';
    plugins = [
      pkgs.tmuxPlugins.tmux-thumbs
      pkgs.tmuxPlugins.prefix-highlight
      pkgs.tmuxPlugins.yank
      {
        plugin = pkgs.tmuxPlugins.fzf-tmux-url;
        extraConfig = "set -g @fzf-url-bind 'u'";
      }
      {
        plugin = pkgs.tmuxPlugins.resurrect;
        extraConfig = ''
          # set -g @resurrect-strategy-nvim 'session'
          # set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-processes '"~bin/vim->vim -S"'
        '';
      }
      {
        plugin = pkgs.tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '1' # minutes
        '';
      }
    ];
  };
}
