{ pkgs, lib, config, ... }: {

  config = lib.mkIf config.profile.battery {

    powerManagement = {
      enable = lib.mkDefault true;
      # Run powertop --calibrate at first
      # powertop --auto-run will run at boot
      powertop.enable = lib.mkDefault true;
    };

    systemd = {
      # Hibernate after 45 minutes of sleep instead of waiting til battery runs out
      sleep.extraConfig = "HibernateDelaySec=45m";

      services.hibernate-critical-battery = {
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
