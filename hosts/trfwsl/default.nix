{
  hostName,
  user,
  ...
}:
{
  system.stateVersion = "26.05";
  networking.hostName = hostName;

  wsl = {
    enable = true;
    defaultUser = user;
    # No interop.register: WSL 2.9+ keeps its own .exe handler and makes
    # binfmt_misc read-only, so re-registering it only fails systemd-binfmt
    # and every switch (https://github.com/nix-community/NixOS-WSL/issues/1109).
  };

  trf.wsl.gpu.enable = true;

  # ── sops-nix: decrypt secrets from repo at activation ─────────────────
  sops = {
    defaultSopsFile = ../../secrets/trfwsl.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  services.ollama.enable = true;

  # No homelab until trflab: Mullvad's split tunneling can't run on WSL's
  # 6.18 kernel. Last declaration: `git show 76e9d16:hosts/trfwsl/default.nix`.
}
