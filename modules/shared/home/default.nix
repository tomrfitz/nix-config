{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./firefox.nix
    ./fastfetch.nix
    ./editors.nix
    ./ghostty.nix
  ];

  home.stateVersion = "24.11";

  # ── Session environment ────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "zeditor";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    VCPKG_ROOT = "$HOME/vcpkg";
    OLLAMA_GPU_LAYERS = "-1";
    OLLAMA_KEEP_ALIVE = "5m";
    PYTORCH_ENABLE_MPS_FALLBACK = "1";
    PYTORCH_MPS_HIGH_WATERMARK_RATIO = "0.0";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
  ];

  # ── Other programs with native modules ─────────────────────────────────
  programs.alacritty.enable = true;
  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.fd.enable = true;
  programs.kitty.enable = true;
  programs.ripgrep.enable = true;
  programs.jq.enable = true;
  programs.btop.enable = true;
  programs.htop.enable = true;
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = false;
  };
  programs.lazygit.enable = true;

  # ── Tmux ──────────────────────────────────────────────────────────────
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    mouse = true;
    historyLimit = 50000;
    escapeTime = 10;
    baseIndex = 1;
    keyMode = "vi";
  };

  # ── SSH ──────────────────────────────────────────────────────────────
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        extraOptions = {
          ControlMaster = "auto";
          ControlPath = "~/.ssh/sockets/%r@%h-%p";
          ControlPersist = "600";
        };
      };
    };
  };

  # Ensure the SSH ControlPath directory exists
  home.file.".ssh/sockets/.keep".text = "";

  programs.home-manager.enable = true;

  # ── Topgrade ──────────────────────────────────────────────────────────
  programs.topgrade = {
    enable = true;
    settings = {
      misc = {
        pre_sudo = false;
        disable = [ "nix" ];
        cleanup = true;
        skip_notify = true;
        no_retry = true;
        no_self_update = true;
      };
      git = {
        max_concurrency = 2;
        repos = [
          "~/Developer/*"
        ];
      };
    };
  };

  # ── Agenix secrets ───────────────────────────────────────────────────
  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519_agenix" ];
  age.secrets = {
    test-secret.file = ../../../secrets/test-secret.age;
  };
}
