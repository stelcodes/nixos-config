{ pkgs, ... }: {
  # These packages are needed for tmux-yank to work on remote tmux instances (Xserver and wayland support)
  home.packages = [ pkgs.xsel pkgs.wl-clipboard ];

  systemd.user.services.tmux = {
    Unit = {
      Description = "tmux default session";
    };
    Service = {
      Type = "forking";
      Environment = [
        "PATH=/home/%u/.nix-profile/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
      ];
      ExecStart = "${pkgs.tmux}/bin/tmux new-session -d";
      ExecStop = [
        "${pkgs.tmux-snapshot}/bin/tmux-snapshot quiet"
        "${pkgs.tmux}/bin/tmux kill-server"
      ];
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    prefix = "M-a";
    terminal = "screen-256color";
    secureSocket = false;
    extraConfig = ''
      # Custom Keybindings
      bind -n M-h previous-window
      bind -n M-l next-window
      bind -n M-H select-pane -L
      bind -n M-L select-pane -R
      bind -n M-J select-pane -D
      bind -n M-K select-pane -U
      bind -n M-Q kill-pane
      bind -n M-s choose-tree -s
      bind -n M-S switch-client -l
      bind -n M-f copy-mode
      bind -n M-w new-window -a -c "#{pane_current_path}"
      bind -n M-W select-window -l
      bind -n M-t command-prompt 'new-session -s %%'
      bind -n M-r command-prompt 'rename-session %%'
      bind -n M-c source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"
      bind -n M-C run-shell -b rebuild
      bind -n M-x split-window -v -c "#{pane_current_path}"
      bind -n M-v split-window -h -c "#{pane_current_path}"
      bind -n M-< swap-window -d -t -1
      bind -n M-> swap-window -d -t +1

      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      # Use default-command instead of default-shell to avoid unwanted login shell behavior
      set -g default-command "exec ${pkgs.fish}/bin/fish";
      # Fixes tmux escape input lag, see https://git.io/JtIsn
      set -sg escape-time 10
      set -g focus-events on
      set -g renumber-windows on
      set -g update-environment "WAYLAND_DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK I3SOCK"

      # From nord tmux plugin
      set -g status-interval 1
      set -g status on
      set -g status-justify left
      set -g status-style bg=black,fg=white
      set -g pane-border-style bg=default,fg=brightblack
      set -g pane-active-border-style bg=default,fg=blue
      set -g display-panes-colour black
      set -g display-panes-active-colour brightblack
      set -g clock-mode-colour cyan
      set -g message-style bg=brightblack,fg=cyan
      set -g message-command-style bg=brightblack,fg=cyan
      set -g status-left "#[fg=black,bg=cyan,bold] #S "
      set -g status-right "#{?client_prefix,#[fg=black#,bg=cyan] M-a ,}#[fg=white,bg=brightblack] %I:%M %p #{?pane_in_mode,#[fg=black#,bg=yellow#,bold],#[fg=black#,bg=cyan#,bold]} #H "
      set -g window-status-format "#[fg=white,bg=black] #I #W #F "
      set -g window-status-current-format "#[fg=white,bg=brightblack] #I #W #F "
      set -g window-status-separator ""
    '';
    plugins = [
      pkgs.tmuxPlugins.yank
      {
        plugin = pkgs.tmuxPlugins.tmux-thumbs;
        extraConfig = ''
          set -g @thumbs-command 'echo -n {} | ${pkgs.wl-clipboard}/bin/wl-copy'
        '';
      }
      {
        plugin = pkgs.tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
    ];
  };
}
