{
  lib,
  user,
  isWSL,
  ...
}:
{
  imports = [
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

  # ── Boot ─────────────────────────────────────────────────────────────
  # Systemd stage 1: faster, more reliable than scripted initrd.
  # WSL has no real boot process.
  boot.initrd.systemd.enable = lib.mkIf (!isWSL) true;

  # ── Nix daemon scheduling ────────────────────────────────────────────
  # Deprioritize builds so media services (Plex, *arr) aren't starved.
  nix.daemonCPUSchedPolicy = "batch";
  nix.daemonIOSchedClass = "idle";
  nix.daemonIOSchedPriority = 7;
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = 250;

  # ── Time zone ─────────────────────────────────────────────────────────
  # WSL: geoclue (used by automatic-timezoned) has no location provider,
  # so set timezone explicitly and sync time from Windows clock.
  # Native: use geolocation-based automatic detection.
  time.timeZone = lib.mkIf isWSL "America/New_York";
  services.automatic-timezoned.enable = !isWSL;

  # Don't drop to emergency shell on boot failure — headless servers hang.
  systemd.enableEmergencyMode = false;

  # ── Tailscale ──────────────────────────────────────────────────────────
  services.tailscale.enable = true;

  # ── SSH ───────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      MaxAuthTries = 3;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
      X11Forwarding = false;
      UseDns = false;
      StreamLocalBindUnlink = true;
    };
  };

  # Prevent TOFU attacks — pre-populate host keys for common forges.
  programs.ssh.knownHosts = {
    "github.com".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    "gitlab.com".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
    "git.sr.ht".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
  };

  # ── Terminfo ──────────────────────────────────────────────────────────
  # Extra terminfo entries so SSH sessions from Ghostty/foot/kitty work.
  environment.enableAllTerminfo = true;

  # ── 1Password CLI ────────────────────────────────────────────────────
  programs._1password.enable = true;
}
