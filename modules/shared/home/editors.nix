{
  pkgs,
  lib,
  ...
}:
{
  # ── Helix ──────────────────────────────────────────────────────────────
  programs.helix = {
    enable = true;
    settings = {
      # Stylix overrides this with its generated Base16 theme
      theme = lib.mkDefault "flexoki-dark";
    };
    themes = {
      flexoki-dark = lib.importTOML ../../../config/helix-flexoki-dark.toml;
      flexoki-light = lib.importTOML ../../../config/helix-flexoki-light.toml;
    };
  };

  # ── Zed ───────────────────────────────────────────────────────────────
  programs.zed-editor = {
    enable = true;
    mutableUserSettings = true;

    extensions = [
      "color-highlight"
      "colored-zed-icons-theme"
      "dockerfile"
      "editorconfig"
      "flexoki-themes"
      "git-firefly"
      "html"
      "java"
      "latex"
      "make"
      "markdownlint"
      "material-icon-theme"
      "nix"
      "opencode"
      "tombi"
      "toml"
      "typst"
      "powershell"
    ];

    userSettings = {
      agent_servers = {
        opencode.type = "registry";
        github-copilot.type = "registry";
      };
      load_direnv = "shell_hook";
      session = {
        trust_all_worktrees = true;
      };
      which_key = {
        enabled = true;
      };
      active_pane_modifiers = {
        inactive_opacity = 1.0;
        border_size = 0.0;
      };
      use_system_window_tabs = true;
      soft_wrap = "bounded";
      preferred_line_length = 80;
      lsp_document_colors = "inlay";
      colorize_brackets = false;
      centered_layout = {
        left_padding = 0.2;
      };
      lsp = {
        tombi = {
          binary.arguments = [
            "lsp"
            "-vv"
          ];
        };
        tinymist = {
          settings.exportPdf = "onSave";
          initialization_options.preview.background.enabled = true;
        };
      };
      notification_panel.default_width = 300.0;
      outline_panel.folder_icons = true;
      agent = {
        default_width = 400.0;
        inline_assistant_model = {
          provider = "copilot_chat";
          model = "claude-opus-4.6";
        };
        favorite_models = [
          {
            provider = "copilot_chat";
            model = "gpt-5.2";
          }
          {
            provider = "google";
            model = "gemini-3-pro-preview";
          }
        ];
        use_modifier_to_send = false;
        default_profile = "write";
        dock = "left";
        default_model = {
          provider = "zed.dev";
          model = "claude-sonnet-4-5";
        };
      };
      ui_font_size = lib.mkForce 14.0;
      tasks.prefer_lsp = true;
      tab_bar.show = true;
      always_treat_brackets_as_autoclosed = true;
      show_signature_help_after_edits = true;
      audio = {
        "experimental.auto_microphone_volume" = true;
        "experimental.rodio_audio" = true;
      };
      diagnostics.inline.enabled = true;
      indent_guides = {
        coloring = "indent_aware";
        background_coloring = "disabled";
      };
      toolbar.code_actions = true;
      scroll_beyond_last_line = "one_page";
      minimap = {
        max_width_columns = 80;
        show = "auto";
        current_line_highlight = "all";
      };
      tabs = {
        show_diagnostics = "errors";
        file_icons = true;
        git_status = true;
        show_close_button = "hover";
      };
      title_bar = {
        show_branch_icon = true;
        show_menus = false;
      };
      project_panel = {
        hide_hidden = false;
        hide_root = true;
        git_status = true;
        folder_icons = true;
        file_icons = true;
        entry_spacing = "comfortable";
        dock = "right";
      };
      git_panel = {
        tree_view = true;
        collapse_untracked_diff = false;
        sort_by_path = true;
        status_style = "label_color";
        default_width = 300.0;
        dock = "right";
      };
      icon_theme = {
        mode = "system";
        light = "Colored Zed Icons Theme Light";
        dark = "Colored Zed Icons Theme Dark";
      };
      disable_ai = false;
      calls.mute_on_join = true;
      edit_predictions = {
        mode = "subtle";
        copilot = {
          enable_next_edit_suggestions = true;
          proxy = null;
          proxy_no_verify = null;
          enterprise_uri = null;
        };
      };
      format_on_save = "on";
      tab_size = 4;
      base_keymap = "VSCode";
      # On macOS, Zed uses native system-responsive theming (Stylix disabled).
      # On NixOS, Stylix manages the theme via HM specialisations.
      theme = lib.mkIf pkgs.stdenv.isDarwin {
        mode = "system";
        light = "Flexoki Light";
        dark = "Flexoki Dark";
      };
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      buffer_font_family = lib.mkForce "Atkinson Hyperlegible Mono";
      ui_font_family = lib.mkForce "Atkinson Hyperlegible Mono";
      terminal.font_family = lib.mkForce "Atkinson Hyperlegible Mono";
      bottom_dock_layout = "right_aligned";
      buffer_font_features.calt = true;
      ui_font_features.calt = true;
      inlay_hints = {
        show_background = false;
        show_type_hints = true;
        show_parameter_hints = true;
        show_other_hints = true;
        toggle_on_modifiers_press.shift = true;
      };
      languages = {
        Markdown = {
          soft_wrap = "none";
        };
        Nix = {
          preferred_line_length = 100;
          tab_size = 2;
          language_servers = [
            "nixd"
            "!nil"
          ];
          formatter.external = {
            command = "nixfmt";
            arguments = [
              "--quiet"
              "--"
            ];
          };
        };
        "Shell Script" = {
          formatter.external = {
            command = "shfmt";
            arguments = [
              "--filename"
              "{buffer_path}"
              "--indent"
              "4"
            ];
          };
        };
        TOML = {
          formatter.language_server.name = "tombi";
        };
        YAML = {
          formatter = "language_server";
        };
        Java = {
          formatter.external = {
            command = "clang-format";
            arguments = [ "--assume-filename={buffer_path}" ];
          };
        };
        Python = {
          language_servers = [
            "ty"
            "ruff"
            "!basedpyright"
            "!pyrefly"
            "!pyright"
            "!pylsp"
          ];
        };
      };
    };
  };
}
