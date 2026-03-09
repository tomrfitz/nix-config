{
  lib,
  user,
  isWSL,
  ...
}:
{
  imports = [
    ./user.nix
    ./remote-build-cache.nix
    ./auto-update.nix
    ./homelab
  ]
  ++ lib.optionals (!isWSL) [ ./hardening.nix ]
  ++ lib.optionals isWSL [
    ./wsl-gpu.nix
    # Stop WSL from overwriting /etc/resolv.conf — resolved manages it instead.
    # Tailscale and Mullvad both integrate with resolved natively for split-DNS.
    {
      wsl.wslConf.network.generateResolvConf = false;
      services.resolved.enable = true;
      # MagicDNS (100.100.100.100) resolves *.ts.net via tailscale0's per-link
      # DNS. Global nameservers provide general resolution — Mullvad overrides
      # these when connected, and they serve as fallback when disconnected.
      networking.nameservers = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    }
  ];

  programs.zsh.enable = true;

  programs.nh.enable = true;

  # ── Time zone ─────────────────────────────────────────────────────────
  # WSL: geoclue (used by automatic-timezoned) has no location provider,
  # so set timezone explicitly and sync time from Windows clock.
  # Native: use geolocation-based automatic detection.
  time.timeZone = lib.mkIf isWSL "America/New_York";
  services.automatic-timezoned.enable = !isWSL;

  # ── Tailscale ──────────────────────────────────────────────────────────
  services.tailscale.enable = true;

  # ── SSH ───────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      MaxAuthTries = 3;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
    };
  };

  # ── 1Password CLI ────────────────────────────────────────────────────
  programs._1password.enable = true;
}
