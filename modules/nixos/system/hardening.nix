{
  # ── Kernel hardening ────────────────────────────────────────────────
  boot.kernel.sysctl = {
    # Hide kernel pointers from non-root
    "kernel.kptr_restrict" = 2;
    # Restrict dmesg to root
    "kernel.dmesg_restrict" = 1;
    # Only allow ptrace on child processes
    "kernel.yama.ptrace_scope" = 1;

    # Ignore ICMP redirects (prevent MITM route injection)
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    # SYN flood protection
    "net.ipv4.tcp_syncookies" = 1;
    # Ignore broadcast pings (smurf attack mitigation)
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    # Silence bogus ICMP error responses
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    # Log packets with impossible source addresses
    "net.ipv4.conf.all.log_martians" = 1;
  };

  # ── Firewall ────────────────────────────────────────────────────────
  # nftables backend (modern replacement for iptables)
  networking.nftables.enable = true;

  # ── fail2ban ────────────────────────────────────────────────────────
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      multipliers = "2 4 8 16 32 64";
      maxtime = "168h";
      overalljails = true;
    };
    jails.sshd.settings = {
      maxretry = 3;
      bantime = "2h";
    };
  };

  # ── sudo-rs ─────────────────────────────────────────────────────────
  # Memory-safe Rust implementation of sudo
  security.sudo-rs.enable = true;
}
