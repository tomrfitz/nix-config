{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.stateVersion = "24.11";

  # ── Packages (things without a dedicated programs.* module) ────────────
  home.packages = with pkgs; [
    # dev toolchains
    rustup
    go
    nodejs
    python3
    deno
    dart
    elixir
    lua
    php
    zig
    vlang
    c3c
    openjdk
    typst
    nasm

    # build tools
    cmake
    gnumake
    ninja
    bear
    automake
    autoconf-archive
    ccache
    clang-tools
    cppcheck
    doxygen
    boost
    rapidjson
    raylib
    libffi
    gst_all_1.gstreamer
    qt6Packages.qtbase
    wxGTK32

    # python tools
    # poetry  # broken on aarch64-darwin (rapidfuzz atomics failure) — revisit later
    ruff
    ty
    beets
    termdown
    virtualenv

    # nix tooling
    nixd
    nil
    nixfmt
    alejandra

    # utilities
    _1password-cli
    coreutils
    findutils
    curl
    wget
    tree
    gnused
    gnutar
    gnugrep
    gawk
    aria2
    duf
    dust
    git-filter-repo
    iperf3
    inetutils
    pandoc
    pass
    pdfgrep
    shellcheck
    shfmt
    silver-searcher
    speedtest-cli
    stow
    streamlink
    texinfo
    tldr
    ansifilter
    fontforge
    termshot
    lf
    lsd
    micro
    kakoune
    witr
    todo-txt-cli
    timewarrior
    taskwarrior-tui
    texlive.combined.scheme-full
    gtypist
    ncspot
    spotifyd
    mailsy
    gemini-cli
    powershell
    cargo-update
    cargo-cache
    # gossip  # broken on aarch64-darwin (SDL2 CMake version conflict) — revisit later

    # fun
    _2048-in-terminal
    cbonsai
    cowsay
    figlet
    fortune
    pipes
    # cava  # broken on aarch64-darwin (unity-test build failure) — revisit later
    mufetch

    # fonts (migrated from Homebrew casks)
    aporetic
    atkinson-hyperlegible-mono
    fira-code
    nerd-fonts.hack
    iosevka-bin
    nerd-fonts.iosevka-term
    nerd-fonts.jetbrains-mono
    maple-mono.NF
    monaspace
    nerd-fonts.symbols-only
  ];

  # ── Session environment ────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "zed";
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

  # ── Zsh ────────────────────────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      ls = "eza --group-directories-first --icons --hyperlink --time-style=long-iso";
      sa = "source ~/.zshrc && echo \"ZSH aliases sourced.\"";
      histrg = "cat ~/.zsh_history | grep";
    };

    envExtra = ''
      [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
    '';

    profileExtra = ''
      if [[ "$TERM_PROGRAM" != "vscode" && "$TERM_PROGRAM" != "zed" ]]; then
        command -v fastfetch &>/dev/null && fastfetch
      fi
    '';

    completionInit = ''
      autoload -Uz compinit
      compdump="$HOME/.zcompdump"
      if [[ ! -f "$compdump" || -n $(find "$compdump" -mtime +1 2>/dev/null) ]]; then
        compinit
      else
        compinit -C
      fi
    '';

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        setopt CORRECT
        typeset -U path
      '')

      ''
        # JJ completions (after compinit)
        if command -v jj &>/dev/null; then
          source <(COMPLETE=zsh jj)
        fi

        # Docker completions
        [ -d "$HOME/.docker/completions" ] && fpath=("$HOME/.docker/completions" ''${fpath[@]})

        # uv completions
        if command -v uv &>/dev/null; then
          eval "$(uv generate-shell-completion zsh)"
          eval "$(uvx --generate-shell-completion zsh)"
        fi

        # Mole shell completion
        if output="$(mole completion zsh 2>/dev/null)"; then eval "$output"; fi

        # Source custom environment file if it exists
        [ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

        function set_win_title() {
          echo -ne "\033]0; $(basename "$PWD") \007"
        }
        starship_precmd_user_func="set_win_title"
      ''
    ];

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh";
      }
    ];
  };

  # ── Starship ───────────────────────────────────────────────────────────
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = lib.importTOML ../../config/starship.toml;
  };

  # ── Git ────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;

    lfs.enable = true;

    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJAf+U5Lj9RGzpxZJWVBTFpEAIqY2oTQor3URBBzWY2v";
      signByDefault = true;
      format = "ssh";
    };

    ignores = [
      ".DS_Store"
      ".vscode"
    ];

    settings = {
      user = {
        name = "Thomas FitzGerald";
        email = "tomrfitz@gmail.com";
      };
      init.defaultBranch = "main";
      core = {
        preloadindex = true;
        fscache = true;
      };
      diff = {
        algorithm = "histogram";
        colorMoved = "default";
      };
      pull.rebase = false;
      push = {
        default = "current";
        followTags = true;
      };
      fetch = {
        prune = true;
        parallel = 0;
      };
      rerere.enabled = true;
      rebase = {
        autoStash = true;
        updateRefs = true;
      };
      merge.conflictStyle = "zdiff3";
    };
  };

  # ── Delta (git pager) ─────────────────────────────────────────────────
  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      line-numbers = true;
      hyperlinks = true;
    };
  };

  # ── Atuin (shell history) ──────────────────────────────────────────────
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      dotfiles.enabled = true;
      enter_accept = true;
      sync.records = true;
    };
  };

  # ── Zoxide (smart cd) ─────────────────────────────────────────────────
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # ── Fzf ────────────────────────────────────────────────────────────────
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # ── Ghostty ────────────────────────────────────────────────────────────
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "light:Flexoki Light,dark:Flexoki Dark";
      quit-after-last-window-closed = false;
      clipboard-read = "allow";
      clipboard-write = "allow";
      window-padding-balance = true;
      window-theme = "system";
      window-height = 36;
      window-width = 130;
      bold-is-bright = true;
      cursor-style = "bar";
      font-thicken = true;
      font-family = "Atkinson Hyperlegible Mono";
    };
  };

  # ── Other programs with native modules ─────────────────────────────────
  programs.alacritty.enable = true;
  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.fd.enable = true;
  # ── Firefox ────────────────────────────────────────────────────────────
  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;

      ExtensionSettings =
        let
          amo = slug: {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
          };
        in
        {
          # privacy & security
          "uBlock0@raymondhill.net" = amo "ublock-origin";
          "addon@darkreader.org" = amo "darkreader";
          "skipredirect@sblask" = amo "skip-redirect";
          "gdpr@cavi.au.dk" = amo "consent-o-matic";
          "@contain-facebook" = amo "facebook-container";
          "@testpilot-containers" = amo "multi-account-containers";

          # passwords & auth
          "{d634138d-c276-4fc8-924b-40a0ea21d284}" = amo "1password-x-password-manager";
          "{fdacee2c-bab4-490d-bc4b-ecdd03d5d68a}" = amo "nos2x-fox";

          # youtube
          "sponsorBlocker@ajay.app" = amo "sponsorblock";
          "deArrow@ajay.app" = amo "dearrow";
          "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}" = amo "youtube-addon";

          # twitch
          "firefox@betterttv.net" = amo "betterttv";
          "frankerfacez@frankerfacez.com" = amo "frankerfacez";
          "{76ef94a4-e3d0-4c6f-961a-d38a429a332b}" = amo "ttv-lol-pro";
          "moz-addon-prod@7tv.app" = {
            installation_mode = "normal_installed";
            install_url = "https://extension.7tv.gg/v3.1.13/ext.xpi";
          };

          # reddit
          "jid1-xUfzOsOFlzSOXg@jetpack" = amo "reddit-enhancement-suite";
          "{4c421bb7-c1de-4dc6-80c7-ce8625e34d24}" = amo "load-reddit-images-directly";

          # twitter / bluesky
          "{ef32ca60-1728-4011-a585-4de439fe7ba7}" = amo "better-twitter-extension";
          "{5cce4ab5-3d47-41b9-af5e-8203eea05245}" = amo "control-panel-for-twitter";
          "sky-follower-bridge@ryo.kawamata" = amo "sky-follower-bridge";
          "jesse@adhdjesse.com" = amo "skylink-bluesky-did-detector";

          # steam / gaming
          "firefox-extension@steamdb.info" = amo "steam-database";
          "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}" = amo "augmented-steam";
          "{2b6c25c8-0c7e-4692-957f-c4ae6af0c34b}" = amo "improve-crunchyroll";

          # productivity & tools
          "firefox@tampermonkey.net" = amo "tampermonkey";
          "clipper@obsidian.md" = amo "web-clipper-obsidian";
          "notes@mozilla.com" = amo "notes-by-firefox";
          "sabre@simplify.jobs" = amo "simplify-jobs";
          "{cb31ec5d-c49a-4e5a-b240-16c767444f62}" = amo "indie-wiki-buddy";
          "historia@eros.man" = amo "historia";
          "{799c0914-748b-41df-a25c-22d008f9e83f}" = amo "web-scrobbler";

          # browser UI
          "{3c078156-979c-498b-8990-85f7987dd929}" = amo "sidebery";
          "ATBC@EasonWong" = amo "adaptive-tab-bar-colour";
          "{a1f01957-5419-4d40-9937-bdf7bba038b4}" = amo "chameleon-dynamic-theme-fixed";

          # dev tools
          "@react-devtools" = amo "react-devtools";
          "{7962ff4a-5985-4cf2-9777-4bb642ad05b8}" = amo "svg-gobbler";

          # media
          "open_in_iina_firefox@iina.io" = amo "open-in-iina-x";
          "audiocontextsuspender@h43z" = amo "audiocontext-suspender";

          # monitoring
          "{ef87d84c-2127-493f-b952-5b4e744245bc}" = amo "aw-watcher-web";

          # external (non-AMO)
          "zotero@chnm.gmu.edu" = {
            installation_mode = "normal_installed";
            install_url = "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.195.xpi";
          };
        };
    };
  };
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
  # ── Helix ──────────────────────────────────────────────────────────────
  programs.helix = {
    enable = true;
    settings = {
      theme = "flexoki-dark";
    };
    themes = {
      flexoki-dark = lib.importTOML ../../config/helix-flexoki-dark.toml;
      flexoki-light = lib.importTOML ../../config/helix-flexoki-light.toml;
    };
  };
  # ── Neovim ─────────────────────────────────────────────────────────────
  programs.neovim = {
    enable = true;
    defaultEditor = false;
    viAlias = true;
    vimAlias = true;
    initLua = ''
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.smartindent = true
      vim.opt.termguicolors = true
      vim.opt.signcolumn = "yes"
      vim.opt.clipboard = "unnamedplus"
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
    '';
  };
  programs.vscode.enable = true;

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

  # ── Fastfetch ──────────────────────────────────────────────────────────
  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
      logo.padding = {
        top = 2;
        left = 1;
        right = 2;
      };
      display.separator = "  ";
      modules = [
        # Title
        {
          type = "title";
          format = "{#1}╭───────────── {#}{user-name-colored}";
        }
        # System Information
        {
          type = "custom";
          format = "{#1}│ {#}System Information";
        }
        {
          type = "os";
          key = "{#separator}│  {#keys}󰍹 OS";
        }
        {
          type = "kernel";
          key = "{#separator}│  {#keys}󰒋 Kernel";
        }
        {
          type = "uptime";
          key = "{#separator}│  {#keys}󰅐 Uptime";
        }
        {
          type = "packages";
          key = "{#separator}│  {#keys}󰏖 Packages";
          format = "{all}";
        }
        {
          type = "custom";
          format = "{#1}│";
        }
        # Desktop Environment
        {
          type = "custom";
          format = "{#1}│ {#}Desktop Environment";
        }
        {
          type = "de";
          key = "{#separator}│  {#keys}󰧨 DE";
        }
        {
          type = "wm";
          key = "{#separator}│  {#keys}󱂬 WM";
        }
        {
          type = "wmtheme";
          key = "{#separator}│  {#keys}󰉼 Theme";
        }
        {
          type = "display";
          key = "{#separator}│  {#keys}󰹑 Resolution";
        }
        {
          type = "shell";
          key = "{#separator}│  {#keys}󰞷 Shell";
        }
        {
          type = "terminalfont";
          key = "{#separator}│  {#keys}󰛖 Font";
        }
        {
          type = "custom";
          format = "{#1}│";
        }
        # Hardware Information
        {
          type = "custom";
          format = "{#1}│ {#}Hardware Information";
        }
        {
          type = "cpu";
          key = "{#separator}│  {#keys}󰻠 CPU";
        }
        {
          type = "gpu";
          key = "{#separator}│  {#keys}󰢮 GPU";
        }
        {
          type = "memory";
          key = "{#separator}│  {#keys}󰍛 Memory";
        }
        {
          type = "disk";
          key = "{#separator}│  {#keys}󰋊 Disk (/)";
          folders = "/";
        }
        {
          type = "custom";
          format = "{#1}│";
        }
        # Colors
        {
          type = "colors";
          key = "{#separator}│";
          symbol = "circle";
        }
        # Footer
        {
          type = "custom";
          format = "{#1}╰───────────────────────────────╯";
        }
      ];
    };
  };

  # ── Jujutsu ────────────────────────────────────────────────────────────
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Thomas FitzGerald";
        email = "tomrfitz@gmail.com";
      };
    };
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
        ignore_failures = [ ];
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
      containers = {
        ignored_containers = [
          "flixor-backend:latest"
          "flixor-frontend:latest"
        ];
      };
    };
  };

  # ── Agenix secrets ───────────────────────────────────────────────────
  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519_agenix" ];
  age.secrets = {
    test-secret.file = ../../secrets/test-secret.age;
  };
}
