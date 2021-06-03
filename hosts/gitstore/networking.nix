{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [ "8.8.8.8" ];
    defaultGateway = "68.183.144.1";
    defaultGateway6 = "2604:a880:800:10::1";
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          {
            address = "68.183.151.244";
            prefixLength = 20;
          }
          {
            address = "10.17.0.9";
            prefixLength = 16;
          }
        ];
        ipv6.addresses = [
          {
            address = "2604:a880:800:10::1a:4001";
            prefixLength = 64;
          }
          {
            address = "fe80::d07a:c3ff:fe9f:1866";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [{
          address = "68.183.144.1";
          prefixLength = 32;
        }];
        ipv6.routes = [{
          address = "2604:a880:800:10::1";
          prefixLength = 128;
        }];
      };

    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="d2:7a:c3:9f:18:66", NAME="eth0"
    ATTR{address}=="ae:db:b1:ef:7d:92", NAME="eth1"
  '';
}
