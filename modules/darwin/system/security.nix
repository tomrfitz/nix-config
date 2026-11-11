_: {
  services.openssh = {
    enable = true;
    # Keys only; see AGENTS.md § Headless Macs
    extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
    '';
  };

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };
}
