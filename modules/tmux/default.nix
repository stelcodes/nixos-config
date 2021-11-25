{ pkgs, ... }: {
  config = {
    environment.systemPackages = [ pkgs.tmux ];
    environment.etc."tmux.conf".text = let
      continuumSaveScript =
        "${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/scripts/continuum_save.sh";
    in ''
      set  -g default-terminal "screen-256color"
      set  -g base-index      1
      setw -g pane-base-index 1
      set -g status-keys vi
      set -g mode-keys   vi
      setw -g aggressive-resize off
      setw -g clock-mode-style  24
      set  -s escape-time       10
      set  -g history-limit     2000
      set-option -g prefix M-a

      set -ga terminal-overrides ',alacritty:Tc'

      # https://is.gd/8VKFEY
      set -g focus-events on

      # Custom Keybindings
      bind -n M-h previous-window
      bind -n M-l next-window
      bind -n M-x kill-pane
      bind -n M-d detach
      bind -n M-f new-window -c "#{pane_current_path}"
      bind -n M-s choose-tree -s
      bind -n M-c copy-mode
      bind -n M-r command-prompt 'rename-session %%'
      bind -n M-n command-prompt 'new-session'
      bind -n M-t source-file /etc/tmux.conf \; display-message "Config reloaded!"

      # Fixes tmux escape input lag, see https://git.io/JtIsn
      set -sg escape-time 10

      # Update environment
      set -g update-environment "PATH"

      set -g status-style fg=white,bg=default
      set -g status-justify left
      set -g status-left ""
      # setting status right makes continuum fail! Apparently it uses the status to save itself? Crazy. https://git.io/JOXd9
      set -g status-right "#[fg=yellow,bg=default][#S] #[fg=default,bg=default]in #[fg=green,bg=default]#h#(${continuumSaveScript})"

      run-shell ${pkgs.tmuxPlugins.urlview.rtp}

      run-shell ${pkgs.tmuxPlugins.yank.rtp}

      set -g @resurrect-processes '"~bin/vim->vim -S"'
      run-shell ${pkgs.tmuxPlugins.resurrect.rtp}

      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '1' # minutes
      run-shell ${pkgs.tmuxPlugins.continuum.rtp}
    '';
  };
}
