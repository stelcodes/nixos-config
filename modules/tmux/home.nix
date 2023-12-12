{ pkgs, config, systemConfig, ... }:
let
  theme = systemConfig.theme.set;
in
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    prefix = "M-a";
    terminal = "tmux-256color";
    secureSocket = false; # Careful, this will mess with tmux-resurrect
    plugins = [
      pkgs.tmuxPlugins.yank
      # Got this kinda working but honestly tmux-thumbs is fine, it just has this annoying issue: https://github.com/fcsonline/tmux-thumbs/issues/129
      # {
      #   plugin = pkgs.tmuxPlugins.fingers.overrideAttrs (prev: {
      #     postInstall = prev.postInstall + ''
      #       sed -i 's/mkdir -p $THIS_CURRENT_DIR\/.cache//g' $target/tmux-fingers.tmux
      #     '';
      #   });
      #   extraConfig = ''
      #     set -g @fingers-main-action 'tmux set-buffer -- {} && test -n "$SWAYSOCK" && echo -n {} | ${pkgs.wl-clipboard}/bin/wl-copy'
      #     set -g @fingers-hint-format "#[fg=${theme.yellow},bold]%s"
      #   '';
      # }
      {
        plugin = pkgs.tmuxPlugins.tmux-thumbs;
        extraConfig = ''
          # Try to copy to every clipboard just to keep the command string simple
          set -g @thumbs-command 'tmux set-buffer -- {}; echo -n {} | ${pkgs.xclip}/bin/xclip; echo -n {} | ${pkgs.wl-clipboard}/bin/wl-copy'
          set -g @thumbs-fg-color '${theme.bg2}'
          set -g @thumbs-bg-color '${theme.yellow}'
          set -g @thumbs-select-fg-color '${theme.bg2}'
          set -g @thumbs-select-bg-color '${theme.red}'
          set -g @thumbs-hint-fg-color '${theme.blue}'
          set -g @thumbs-hint-bg-color '${theme.bg2}'
          set -g @thumbs-position right
        '';
      }
      {
        plugin = pkgs.tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          # Doesn't work because nvim process invokation gets ran without proper quoting
          # set -g @resurrect-processes '~nvim->nvim ~man->man'
        '';
      }
    ];
    extraConfig = ''
      #########################################################################
      # KEYBINDINGS

      bind -n M-h previous-window
      bind -n M-l next-window
      bind -n M-H select-pane -L
      bind -n M-L select-pane -R
      bind -n M-J select-pane -D
      bind -n M-K select-pane -U
      bind -n M-Q kill-pane
      bind -n M-s choose-tree -s
      bind -n M-S switch-client -l
      bind -n M-f thumbs-pick
      bind -n M-space copy-mode
      bind -n M-w new-window -a -c "#{pane_current_path}"
      bind -n M-W select-window -l
      bind -n M-t command-prompt 'new-session -s %%'
      bind -n M-r command-prompt 'rename-session %%'
      bind -n M-R source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"
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

      #########################################################################
      # BEHAVIOR

      # Use default-command instead of default-shell to avoid unwanted login shell behavior
      # Also don't prefix command with exec because it causes tmux-resurrect restore.sh to crash
      set -g default-command ${pkgs.fish}/bin/fish
      # Fixes tmux/neovim escape input lag: https://github.com/neovim/neovim/wiki/FAQ#esc-in-tmux-or-gnu-screen-is-delayed
      set -sg escape-time 10
      set -g focus-events on
      set -g renumber-windows on
      set -g update-environment "WAYLAND_DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK I3SOCK DISPLAY"
      set -g status on
      set -g status-interval 1
      set -g history-limit 8000
      set -sa terminal-features ',foot:RGB,xterm-256color:RGB,tmux-256color:RGB'
      setenv -g COLORTERM truecolor

      #########################################################################
      # APPEARANCE

      set -g status-justify left
      set -g status-style bg=${theme.bg1},fg=${theme.fg}
      set -g pane-border-style bg=default,fg=${theme.bg}
      set -g pane-active-border-style bg=default,fg=${theme.blue}
      set -g display-panes-colour black
      set -g display-panes-active-colour black
      set -g clock-mode-colour '${theme.tmuxPrimary}'
      set -g message-style bg=${theme.bg},fg=${theme.tmuxPrimary}
      set -g message-command-style bg=${theme.bg},fg=${theme.tmuxPrimary}
      set -g status-left "#[fg=${theme.bg},bg=${theme.tmuxPrimary},bold] #S "
      set -g status-left-length 25
      set -g status-right "#{?client_prefix,#[fg=${theme.bg}#,bg=${theme.tmuxPrimary}] M-a ,}#[fg=${theme.bg4},bg=${theme.bg2}] %I:%M %p #{?pane_in_mode,#[fg=${theme.bg}#,bg=${theme.tmuxSecondary}#,bold],#[fg=${theme.bg}#,bg=${theme.tmuxPrimary}#,bold]} #H "
      set -g status-right-length 50
      set -g window-status-format "#[fg=${theme.bg4},bg=${theme.bg1}] #I #W #F "
      set -g window-status-current-format "#[fg=${theme.fg},bg=${theme.bg2}] #I #W #F "
      set -g window-status-separator ""
      set -g mode-style "fg=${theme.fg},bg=${theme.bg2}"
    '';
  };
}
