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
    tmux
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
    EZA_CONFIG_DIR = "$HOME/.config/eza/";
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
        excludesfile = "~/.gitignore";
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
  programs.firefox.enable = true;
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
  programs.helix.enable = true;
  programs.neovim.enable = true;
  programs.vscode.enable = true;

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

  programs.home-manager.enable = true;

  # ── Agenix secrets ───────────────────────────────────────────────────
  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519_agenix" ];
  age.secrets = {
    test-secret.file = ../../secrets/test-secret.age;
  };
}
