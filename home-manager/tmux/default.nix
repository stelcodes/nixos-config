pkgs: {
  # These packages are needed for tmux-yank to work on remote tmux instances (Xserver and wayland support)
  home.packages = [ pkgs.xsel pkgs.wl-clipboard ];
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    keyMode = "vi";
    newSession = true;
    shell = "${pkgs.zsh}/bin/zsh";
    prefix = "M-a";
    # Set to "tmux-256color" normally, but theres this macOS bug https://git.io/JtLls
    terminal = "screen-256color";
    extraConfig = let
      continuumSaveScript =
        "${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/scripts/continuum_save.sh";
    in ''
      set -ga terminal-overrides ',alacritty:Tc'
      # set -as terminal-overrides ',xterm*:sitm=\E[3m'

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
      bind -n M-t source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

      # Fixes tmux escape input lag, see https://git.io/JtIsn
      set -sg escape-time 10

      # Update environment
      set -g update-environment "PATH"

      set -g status-style fg=white,bg=default
      set -g status-justify left
      set -g status-left ""
      # setting status right makes continuum fail! Apparently it uses the status to save itself? Crazy. https://git.io/JOXd9
      set -g status-right "#[fg=yellow,bg=default][#S] #[fg=default,bg=default]in #[fg=green,bg=default]#h#(${continuumSaveScript})"
    '';
    plugins = [
      # pkgs.tmuxPlugins.nord
      {
        plugin = pkgs.tmuxPlugins.fzf-tmux-url;
        extraConfig = "set -g @fzf-url-bind 'u'";
      }
      { plugin = pkgs.tmuxPlugins.yank; }
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
