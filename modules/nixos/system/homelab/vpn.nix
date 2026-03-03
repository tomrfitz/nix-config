# Mullvad VPN network namespace for homelab services.
#
# Creates an isolated network namespace with a WireGuard tunnel to Mullvad.
# Services listed in `trf.homelab.vpn.services` are bound into this namespace —
# their internet traffic routes through Mullvad, and if the tunnel drops they
# lose connectivity entirely (kill-switch by design).
#
# A veth pair bridges the namespace to the host so VPN'd services remain
# reachable from the LAN, Tailscale, and other local services (e.g., Sonarr
# reaching Prowlarr). Services outside the namespace should use the veth IP
# (default 10.200.1.2) instead of localhost to reach VPN'd services.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.trf.homelab;
  vpn = cfg.vpn;
  ns = vpn.namespace;
in
{
  options.trf.homelab.vpn = {
    enable = lib.mkEnableOption "Mullvad VPN namespace for homelab services";

    namespace = lib.mkOption {
      type = lib.types.str;
      default = "mullvad";
      description = "Name of the network namespace.";
    };

    # ── WireGuard / Mullvad config ──────────────────────────────────────

    privateKeyOpRef = lib.mkOption {
      type = lib.types.str;
      description = "1Password op:// reference for the WireGuard private key.";
      example = "op://Vault/mullvad-wg/private-key";
    };

    address = lib.mkOption {
      type = lib.types.str;
      description = "WireGuard interface address assigned by Mullvad (e.g., 10.68.x.x/32).";
    };

    dns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "10.64.0.1" ];
      description = "DNS servers for the VPN namespace (Mullvad default: 10.64.0.1).";
    };

    peer = {
      publicKey = lib.mkOption {
        type = lib.types.str;
        description = "Mullvad server's WireGuard public key.";
      };

      endpoint = lib.mkOption {
        type = lib.types.str;
        description = "Mullvad server endpoint (host:port).";
        example = "198.54.128.82:51820";
      };
    };

    # ── Internal networking ─────────────────────────────────────────────

    vethHostAddr = lib.mkOption {
      type = lib.types.str;
      default = "10.200.1.1";
      description = "Host-side veth address.";
    };

    vethNsAddr = lib.mkOption {
      type = lib.types.str;
      default = "10.200.1.2";
      description = "Namespace-side veth address. Use this to reach VPN'd services from the host.";
    };

    # ── Service binding ─────────────────────────────────────────────────

    services = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        systemd service names to bind into the VPN namespace.
        Typical candidates: prowlarr, sabnzbd, qbittorrent, openbooks.
      '';
      example = [
        "prowlarr"
        "sabnzbd"
        "qbittorrent"
        "openbooks"
      ];
    };
  };

  config = lib.mkIf (cfg.enable && vpn.enable) {

    # ── Namespace setup service ─────────────────────────────────────────

    systemd.services."netns-${ns}" = {
      description = "Mullvad VPN network namespace (${ns})";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        LoadCredential = "op-sa-token:/etc/op/service-account-token";

        ExecStart =
          let
            up = pkgs.writeShellScript "netns-${ns}-up" ''
              set -euo pipefail
              export PATH="${
                lib.makeBinPath [
                  pkgs.iproute2
                  pkgs.wireguard-tools
                  pkgs._1password-cli
                ]
              }:$PATH"

              NS="${ns}"
              WG_IF="wg-$NS"
              VETH_HOST="veth-''${NS}0"
              VETH_NS="veth-''${NS}1"

              # ── Create namespace ────────────────────────────────────
              ip netns add "$NS"
              ip netns exec "$NS" ip link set lo up

              # ── DNS for the namespace ───────────────────────────────
              mkdir -p /etc/netns/"$NS"
              printf '%s\n' ${lib.concatMapStringsSep " " (d: "'nameserver ${d}'") vpn.dns} \
                > /etc/netns/"$NS"/resolv.conf

              # ── veth pair (host ↔ namespace) ────────────────────────
              ip link add "$VETH_HOST" type veth peer name "$VETH_NS"
              ip link set "$VETH_NS" netns "$NS"

              ip addr add ${vpn.vethHostAddr}/30 dev "$VETH_HOST"
              ip link set "$VETH_HOST" up

              ip netns exec "$NS" ip addr add ${vpn.vethNsAddr}/30 dev "$VETH_NS"
              ip netns exec "$NS" ip link set "$VETH_NS" up

              # ── WireGuard interface ─────────────────────────────────
              ip link add "$WG_IF" type wireguard
              ip link set "$WG_IF" netns "$NS"

              # Resolve private key from 1Password
              WG_KEY="$(OP_SERVICE_ACCOUNT_TOKEN="$(cat "$CREDENTIALS_DIRECTORY/op-sa-token")" \
                op read "${vpn.privateKeyOpRef}")"

              ip netns exec "$NS" wg set "$WG_IF" \
                private-key <(printf '%s' "$WG_KEY") \
                peer "${vpn.peer.publicKey}" \
                endpoint "${vpn.peer.endpoint}" \
                allowed-ips "0.0.0.0/0,::0/0"

              ip netns exec "$NS" ip addr add ${vpn.address} dev "$WG_IF"
              ip netns exec "$NS" ip link set "$WG_IF" up

              # ── Routing inside namespace ────────────────────────────
              # Default route through WireGuard
              ip netns exec "$NS" ip route add default dev "$WG_IF"

              # Private subnets route through veth (reach host services, Tailscale, LAN)
              for cidr in 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 100.64.0.0/10; do
                ip netns exec "$NS" ip route add "$cidr" via ${vpn.vethHostAddr} dev "$VETH_NS"
              done
            '';
          in
          "${up}";

        ExecStop =
          let
            down = pkgs.writeShellScript "netns-${ns}-down" ''
              set -euo pipefail
              export PATH="${lib.makeBinPath [ pkgs.iproute2 ]}:$PATH"

              # Deleting the namespace removes all interfaces inside it
              ip netns del "${ns}" || true
              rm -rf /etc/netns/"${ns}"
            '';
          in
          "${down}";
      };
    };

    # ── Bind services into the namespace ────────────────────────────────

    systemd.services = lib.mkMerge (
      map (svc: {
        ${svc} = {
          after = [ "netns-${ns}.service" ];
          requires = [ "netns-${ns}.service" ];
          serviceConfig = {
            NetworkNamespacePath = "/var/run/netns/${ns}";
          };
        };
      }) vpn.services
    );

    # ── Host networking for namespace connectivity ──────────────────────

    # Forward traffic between veth and the host network
    boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkDefault true;

    networking.nat = {
      enable = true;
      internalInterfaces = [ "veth-${ns}0" ];
    };

    # Trust the veth interface (services need to be reachable from host)
    networking.firewall.trustedInterfaces = [ "veth-${ns}0" ];
  };
}
