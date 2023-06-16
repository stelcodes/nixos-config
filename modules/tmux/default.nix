{ pkgs, ... }: {
  systemd.services = {
    tmux-snapshot =
      let
        powerDownTargets = [
          "sleep.target"
          "halt.target"
          "poweroff.target"
          "shutdown.target"
          "reboot.target"
        ];
      in
      {
        before = powerDownTargets;
        wantedBy = powerDownTargets;
        description = "create tmux snapshot";
        serviceConfig = {
          User = "stel";
          Type = "oneshot";
          ExecStart = "${pkgs.tmux-snapshot}/bin/tmux-snapshot";
          Restart = "no";
        };
      };
  };
}
