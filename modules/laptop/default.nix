{ pkgs, ... }: {

  config = {

    # Hibernate after 45 minutes of sleep
    systemd = {
      sleep.extraConfig = "HibernateDelaySec=45m";
    };

    services = {

      # don’t shutdown when power button is short-pressed
      logind.extraConfig = "HandlePowerKey=hibernate";
      logind.lidSwitch = "suspend-then-hibernate";

      cron = {
        enable = true;
        # https://crontab.guru
        systemCronJobs =
          let
            hibernateCriticalBattery = pkgs.writeShellScript "hibernate-critical-battery" ''
              ${pkgs.acpi}/bin/acpi -b | ${pkgs.gawk}/bin/awk -F'[,:%]' '{print $2, $3}' | {
                read -r status capacity
                if [ "$status" = Discharging -a "$capacity" -lt 8 ]; then
                  ${pkgs.systemd}/bin/systemctl hibernate
                fi
              }
            '';
          in
          [
            "* * * * * root ${hibernateCriticalBattery}"
          ];
      };

    };

  };

}
