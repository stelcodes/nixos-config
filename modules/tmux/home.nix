{ pkgs, ... }:
let
  resurrectSaveScript = "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh";
in
{
  # These packages are needed for tmux-yank to work on remote tmux instances (Xserver and wayland support)
  home.packages = [ pkgs.xsel pkgs.wl-clipboard ];

  systemd.user.services.tmux-resurrect-periodic-save = {
    Unit = {
      Description = "Periodically save tmux state via tmux-resurrect plugin";
    };
    Service = {
      Type = "simple";
      ExecStart = pkgs.writeShellScript "tmux-resurrect-periodic-save" ''
        while true; do
          if ${pkgs.toybox}/bin/pgrep tmux; then
            echo "tmux is running, saving state"
            ${resurrectSaveScript} quiet
          else
            echo "tmux is not running"
          fi
          echo "sleeping..."
          sleep 300
        done
      '';
      Restart = "always";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    shell = "${pkgs.fish}/bin/fish";
    prefix = "M-a";
    terminal = "screen-256color";
    extraConfig = ''
      # Options

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

      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      # Fixes tmux escape input lag, see https://git.io/JtIsn
      set -sg escape-time 10

      set -g focus-events on
      set -g renumber-windows on
      set -g update-environment "PATH"

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
