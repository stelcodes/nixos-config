{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [ "8.8.8.8" ];
    defaultGateway = "104.236.192.1";
    defaultGateway6 = "2604:a880:800:10::1";
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          {
            address = "104.236.219.156";
            prefixLength = 18;
          }
          {
            address = "10.17.0.5";
            prefixLength = 16;
          }
        ];
        ipv6.addresses = [
          {
            address = "2604:a880:800:10::226:7001";
            prefixLength = 64;
          }
          {
            address = "fe80::58c0:caff:feac:43ec";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [{
          address = "104.236.192.1";
          prefixLength = 32;
        }];
        ipv6.routes = [{
          address = "2604:a880:800:10::1";
          prefixLength = 32;
        }];
      };

    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="5a:c0:ca:ac:43:ec", NAME="eth0"
    ATTR{address}=="3a:67:6c:ae:6f:a6", NAME="eth1"
  '';
}
