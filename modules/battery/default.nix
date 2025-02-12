{ pkgs, lib, config, ... }: {

  config = lib.mkIf config.profile.battery {

    powerManagement = {
      enable = lib.mkDefault true;
    };

    systemd = {
      # Hibernate after 1 hour of sleep instead of waiting til battery runs out
      sleep.extraConfig = ''
        HibernateDelaySec=1h
        SuspendEstimationSec=1h
      '';

      services.hibernate-critical-battery = {
        enable = false;
        description = "hibernates system when battery gets critically low";
        startAt = "*-*-* *:0/2:00";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "hibernate-critical-battery" ''
            ${pkgs.acpi}/bin/acpi -b | ${pkgs.gawk}/bin/awk -F'[,:%]' '{print $2, $3}' | {
              read -r status capacity
              if [ "$status" = "Discharging" -a "$capacity" -lt 8 ]; then
                ${pkgs.systemd}/bin/systemctl hibernate
              fi
            }
          '';
        };
      };

    };

  };

}
