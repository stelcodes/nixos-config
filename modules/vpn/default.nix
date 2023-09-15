{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.networking.vpnConnections;

  interfaceOpts = { ... }: {
    options = {
      enable = mkEnableOption "Enable VPN connection (using Wireguard).";

      autostart = mkOption {
        default = true;
        example = "true";
        type = types.bool;
        description = "Automatically set up this VPN connection when NixOS boots.";
      };

      killswitch = mkOption {
        default = false;
        example = "true";
        type = types.bool;
        description = "Only allow outgoing traffic through this VPN connection once started.";
      };

      address = mkOption {
        default = "10.2.0.2/32";
        example = "10.2.0.2/32";
        type = types.str;
        description = "The IP address of the interface. See your Wireguard certificate.";
      };

      listenPort = mkOption {
        default = 51820;
        example = 51820;
        type = types.port;
        description = "The port number of the interface.";
      };

      privateKeyFile = mkOption {
        example = "/root/secrets/protonvpn";
        type = types.path;
        description = "The path to a file containing the private key for this interface/peer. Only root should have access to the file. See your Wireguard certificate.";
      };

      dns = {
        enable = mkOption {
          default = true;
          example = "true";
          type = types.bool;
          description = "Enable the DNS provided by Wireguard connection.";
        };

        ip = mkOption {
          default = "10.2.0.1";
          example = "10.2.0.1";
          type = types.str;
          description = "The IP address of the DNS provided by the VPN. See your Wireguard certificate.";
        };
      };

      endpoint = {
        publicKey = mkOption {
          example = "23*********************************************=";
          type = types.str;
          description = "The public key of the VPN endpoint. See your Wireguard certificate.";
        };

        ip = mkOption {
          example = "48.1.3.4";
          type = types.str;
          description = "The IP address of the VPN endpoint. See your Wireguard certificate.";
        };

        port = mkOption {
          default = 51820;
          example = 51820;
          type = types.port;
          description = "The port number of the VPN peer endpoint. See your Wireguard certificate.";
        };
      };
    };
  };


  generate-wg-quick = interfaceName: interfaceCfg:
    let
      chain = "wg-killswitch";
      # Maybe I could allow LAN traffic?
      # --match iprange ! --dst-range 192.168.0.0-192.168.0.255 (for ipv4 addresses only)
      enableKillswitch = cmd: ''
        ${cmd} --new-chain ${chain} || true
        ${cmd} --insert ${chain} ! --out-interface ${interfaceName} --match mark ! --mark $(wg show ${interfaceName} fwmark) --match addrtype ! --dst-type LOCAL -j DROP
        while ${cmd} --delete ${chain} 2; do true; done
        ${cmd} --check OUTPUT --jump ${chain} || ${cmd} --insert OUTPUT --jump ${chain}
      '';
      # disableKillswitch = cmd: "${cmd} --flush ${chain} || true";
    in
    mkIf interfaceCfg.enable
      {
        autostart = interfaceCfg.autostart;
        dns = if interfaceCfg.dns.enable then [ interfaceCfg.dns.ip ] else [ ];
        privateKeyFile = interfaceCfg.privateKeyFile;
        address = [ interfaceCfg.address ];
        listenPort = interfaceCfg.listenPort;
        # preUp = mkIf (!interfaceCfg.killswitch) ''
        #   ${disableKillswitch "iptables"}
        #   ${disableKillswitch "ip6tables"}
        # '';
        postUp = mkIf interfaceCfg.killswitch ''
          ${enableKillswitch "iptables"}
          ${enableKillswitch "ip6tables"}
        '';
        peers = [
          {
            publicKey = interfaceCfg.endpoint.publicKey;
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "${interfaceCfg.endpoint.ip}:${builtins.toString interfaceCfg.endpoint.port}";
          }
        ];
      };
in
{

  # TODO: create assertion that wireguard interface names are 15 chars or less

  options = {
    networking.vpnConnections = mkOption {
      description = mdDoc "Wireguard interfaces.";
      default = { };
      example = { };
      type = with types; attrsOf (submodule interfaceOpts);
    };
  };

  config = {
    networking.wg-quick.interfaces = mapAttrs generate-wg-quick cfg;
  };

  meta.maintainers = with maintainers; [ emmanuelrosa ];
}
