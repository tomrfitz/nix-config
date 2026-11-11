_: {
  services.openssh = {
    enable = true;
    # Keys only; see AGENTS.md § Headless Macs
    extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
    '';
  };

  # Signed software (sshd, Screen Sharing, AirPlay, app-store and notarized
  # apps) still receives connections, which is macOS's default and stays
  # undeclared. What this stops is an unsigned listener, such as a nix-built
  # server bound beyond loopback, until it is allowed by hand.
  networking.applicationFirewall.enable = true;

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };
}
