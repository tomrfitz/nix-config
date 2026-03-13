{
  config,
  pkgs,
  lib,
  sshPublicKey,
  isDarwin,
  isWSL,
  ...
}:
let
  socketPath =
    if isDarwin then
      "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else
      "${config.home.homeDirectory}/.1password/agent.sock";
  # macOS ssh_config needs the path quoted when it contains spaces
  identityAgent = if isDarwin then "\"${socketPath}\"" else socketPath;
in
{
  # ── Session variables ──────────────────────────────────────────────────
  home.sessionVariables = lib.mkIf (isDarwin || isWSL) {
    SSH_AUTH_SOCK = socketPath;
  };

  # Export to systemd user environment so GUI apps can reach the agent
  systemd.user.sessionVariables = lib.mkIf (!isDarwin) {
    SSH_AUTH_SOCK = socketPath;
  };

  # ── SSH client: always use 1Password agent on macOS/WSL ────────────────
  # On plain NixOS, omit IdentityAgent so SSH falls back to SSH_AUTH_SOCK —
  # this preserves forwarded agents from SSH sessions while defaulting to
  # 1Password locally (via zsh envExtra).
  programs.ssh.matchBlocks."*".extraOptions = lib.mkIf (isDarwin || isWSL) {
    IdentityAgent = identityAgent;
  };

  # macOS doesn't have a declarative system-level authorized_keys module,
  # so keep it in HM.
  home.file.".ssh/authorized_keys" = lib.mkIf isDarwin {
    text = ''
      ${sshPublicKey}
    '';
  };

  # ── WSL bridge ─────────────────────────────────────────────────────────
  # Bridge the 1Password Windows SSH agent to a Unix socket via
  # npiperelay + socat. Requires npiperelay.exe on the Windows side
  # (installed to C:\Users\<user>\.local\bin\npiperelay.exe).
  systemd.user.services."1password-ssh-agent-bridge" = lib.mkIf isWSL {
    Unit = {
      Description = "Bridge 1Password Windows SSH agent to Unix socket";
    };
    Install.WantedBy = [ "default.target" ];
    Service =
      let
        npiperelay = "/mnt/c/Users/Thomas FitzGerald/.local/bin/npiperelay.exe";
        # Symlink npiperelay to a path without spaces so socat EXEC: can handle it
        npiprelayLink = pkgs.runCommand "npiperelay-link" { } ''
          mkdir -p $out/bin
          ln -s "${npiperelay}" $out/bin/npiperelay.exe
        '';
        bridge = pkgs.writeShellScript "1password-ssh-bridge" ''
          ${pkgs.coreutils}/bin/rm -f "${socketPath}"
          ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "${socketPath}")"
          exec ${pkgs.socat}/bin/socat \
            UNIX-LISTEN:${socketPath},fork \
            EXEC:"${npiprelayLink}/bin/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork
        '';
      in
      {
        Type = "simple";
        ExecStart = "${bridge}";
        Restart = "on-failure";
        RestartSec = 3;
      };
  };
}
