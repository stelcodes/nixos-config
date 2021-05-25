{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [ "8.8.8.8"
 ];
    defaultGateway = "167.99.112.1";
    defaultGateway6 = "2604:a880:800:10::1";
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="167.99.122.78"; prefixLength=20; }
{ address="10.17.0.7"; prefixLength=16; }
        ];
        ipv6.addresses = [
          { address="2604:a880:800:10::5df:7001"; prefixLength=64; }
{ address="fe80::9828:19ff:fe7f:d1e8"; prefixLength=64; }
        ];
        ipv4.routes = [ { address = "167.99.112.1"; prefixLength = 32; } ];
        ipv6.routes = [ { address = "2604:a880:800:10::1"; prefixLength = 128; } ];
      };
      
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="9a:28:19:7f:d1:e8", NAME="eth0"
    ATTR{address}=="92:2c:17:31:d3:22", NAME="eth1"
  '';
}
