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
    ./homelab
  ]
  ++ lib.optionals (!isWSL) [ ./hardening.nix ]
  ++ lib.optionals isWSL [
    ./wsl-gpu.nix
    # Stop WSL from overwriting /etc/resolv.conf — resolved manages it instead.
    # Tailscale and Mullvad both integrate with resolved natively for split-DNS.
    {
      wsl.wslConf.network.generateResolvConf = false;
      services.resolved = {
        enable = true;
        settings.Resolve.FallbackDNS = [ "1.1.1.1" ];
      };
      networking.nameservers = [ "100.100.100.100" ]; # Tailscale MagicDNS
    }
  ];

  programs.zsh.enable = true;

  programs.nh.enable = true;

  # ── Time zone ─────────────────────────────────────────────────────────
  # Use automatic timezone detection (sets time.timeZone = null internally)
  # Falls back to America/New_York if location detection fails
  services.automatic-timezoned.enable = true;

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
