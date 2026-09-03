;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

;; ── Package management ────────────────────────────────────────────────
;; Purist Nix: packages are provided by Nix via
;; emacsWithPackagesFromUsePackage in modules/shared/home/emacs.nix — it
;; parses `use-package` blocks below and builds the closure. package.el
;; is disabled in early-init.el. The `:ensure t' markers here are read
;; at *build time* by Nix's parser; at runtime use-package's
;; ensure-function is `ignore' so no install attempts run.
;;
;; To add a package: write a `(use-package foo :ensure t ...)` block
;; here and rebuild. To experiment locally without committing, use
;; `nrsl' from this working tree.
(setq use-package-ensure-function 'ignore)

;; ── Shell environment ───────────────────────────────────────────────
;; launchd daemon on macOS inherits a minimal PATH; sync from login shell.
;; system-type check works in --daemon mode (where window-system is nil).
(use-package exec-path-from-shell
    :ensure t
    :if (eq system-type 'darwin)
    :init
    ;; A non-interactive *login* shell ("-l", no "-i") already yields the full
    ;; PATH (nix profiles via /etc/zshenv, brew via ~/.zprofile) without sourcing
    ;; ~/.zshrc — which on this machine runs fastfetch, atuin, starship, zoxide,
    ;; the plugins and compinit, costing ~1.5s on a cold launch for nothing that
    ;; affects PATH. Default args are ("-l" "-i").
    (setq exec-path-from-shell-arguments '("-l"))
    (exec-path-from-shell-initialize))

;; ── Identity ──────────────────────────────────────────────────────────
(setq user-full-name "Thomas FitzGerald"
    user-mail-address "tomrfitz@gmail.com")

;; ── Sane defaults ─────────────────────────────────────────────────────
(delete-selection-mode 1)
(repeat-mode 1)
(savehist-mode 1)
(recentf-mode 1)
(save-place-mode 1)
;; The GUI app is the server (see Server below): a force-quit would drop
;; both lists, so flush them every 5 min (Emacs 31 options; :set handlers,
;; hence setopt).
(setopt recentf-autosave-interval 300
        save-place-autosave-interval 300)
;; Emacs 31: revert VCS-tracked files only — reliable after magit operations,
;; and it stops watching every untracked scratch buffer (newcomers-presets).
(vc-auto-revert-mode 1)
(global-so-long-mode 1)
(global-goto-address-mode 1)
(winner-mode 1)
(column-number-mode 1)
(setq-default display-line-numbers-width 4
              display-line-numbers-grow-only t)
;; Code buffers only (purcell/Doom) — org, dired and the agenda stay clean.
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(show-paren-mode 1)
;; Core's own modern-defaults list (newcomers-presets theme, Emacs 31).
(context-menu-mode 1)
(electric-pair-mode 1)

;; Redirect auto-saves out of working trees (lockfiles/backups disabled
;; below). make-directory is required: Emacs does not create the
;; transform target and auto-saving errors without it.
(let ((auto-save-dir (expand-file-name "auto-saves/" user-emacs-directory)))
  (make-directory auto-save-dir t)
  (setq auto-save-file-name-transforms `((".*" ,auto-save-dir t))))

(setq use-short-answers t
    ;; Cmd-Q / C-x C-c really quit; confirm, since the GUI app is also the
    ;; server. recentf/save-place restore context.
    confirm-kill-emacs 'y-or-n-p
    ;; newcomers-presets: don't lose the system clipboard to a kill; yank
    ;; where point is, not where the mouse is.
    save-interprogram-paste-before-kill t
    mouse-yank-at-point t
    create-lockfiles nil
    make-backup-files nil
    custom-file (expand-file-name "custom.el" user-emacs-directory)
    completion-ignore-case t
    read-buffer-completion-ignore-case t
    read-file-name-completion-ignore-case t
    kill-do-not-save-duplicates t
    ;; init.el/early-init.el are HM symlinks into the store — never ask.
    vc-follow-symlinks t
    ring-bell-function #'ignore
    calendar-week-start-day 1
    calendar-date-style 'iso
    scroll-conservatively 101
    scroll-margin 0)

;; Trackpad: per-pixel smooth scrolling (the macport did this natively).
(pixel-scroll-precision-mode 1)

;; Load custom file if it exists (keeps init.el clean)
(when (file-exists-p custom-file)
    (load custom-file 'noerror))

;; ── Indentation ───────────────────────────────────────────────────────
(setq-default indent-tabs-mode nil
    tab-width 4)
(setq tab-always-indent 'complete)

;; ── Fonts ─────────────────────────────────────────────────────────────
(set-face-attribute 'default nil
    :family "Atkinson Hyperlegible Mono"
    :height 140)
(set-face-attribute 'variable-pitch nil
    :family "Atkinson Hyperlegible Next"
    :height 140)

;; CJK fallback: Pretendard (Korean) → Noto Sans CJK SC (Chinese/shared)
(dolist (script '(hangul kana han cjk-misc))
    (set-fontset-font t script (font-spec :family "Pretendard") nil 'prepend))
(dolist (script '(han cjk-misc))
    (set-fontset-font t script (font-spec :family "Noto Sans CJK SC") nil 'append))

;; ── Theme ─────────────────────────────────────────────────────────────
;; Local Flexoki theme (spec-corrected); platform-aware dark/light switching.
(let ((themes-dir (expand-file-name "themes/" user-emacs-directory)))
    (add-to-list 'custom-theme-load-path themes-dir)
    (add-to-list 'load-path themes-dir))

;; macOS: follow the system appearance. Upstream GNU Emacs has no change
;; notification for it — `ns-system-appearance-change-functions' is an
;; emacs-plus patch, never in nixpkgs' NS build — so auto-dark polls via
;; in-process AppleScript (`ns-do-applescript', 5 s). It uses the hook
;; automatically if that patch is ever applied in emacs.nix.
(use-package auto-dark
    :ensure t
    :if (eq system-type 'darwin)
    :custom (auto-dark-themes '((flexoki-dark) (flexoki-light)))
    :init (auto-dark-mode))

;; Linux: noctalia theme if generated (hosts with the noctalia shell),
;; flexoki-dark fallback elsewhere (e.g. trfwsl's headless daemon).
(when (eq system-type 'gnu/linux)
    (if (file-exists-p (expand-file-name "themes/noctalia-theme.el" user-emacs-directory))
        (load-theme 'noctalia t)
        (load-theme 'flexoki-dark t)))

;; ── Completion ────────────────────────────────────────────────────────
(use-package vertico
    :ensure t
    :init (vertico-mode))

;; Completion UI at the TOP of the frame: on the laptop, hands on the
;; keyboard cover the bottom of the display, where the minibuffer lives.
;; (Emacs 31 supports child frames on TTYs, so `emacsclient -t' frames get
;; the popup too — posframe falls back to the minibuffer only where it can't.)
(use-package vertico-posframe
    :ensure t
    :after vertico
    :custom
    (vertico-posframe-poshandler #'posframe-poshandler-frame-top-center)
    (vertico-posframe-width 100)
    (vertico-posframe-border-width 1)
    :init (vertico-posframe-mode))

(use-package orderless
    :ensure t
    :custom
    (completion-styles '(orderless basic))
    (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
    :ensure t
    :init (marginalia-mode))

(use-package consult
    :ensure t
    :bind (("C-x b"   . consult-buffer)
              ("C-x r b" . consult-bookmark)
              ("M-g g"   . consult-goto-line)
              ("M-g M-g" . consult-goto-line)
              ("M-s l"   . consult-line)
              ("M-s r"   . consult-ripgrep)
              ("M-s f"   . consult-find)))

(use-package embark
    :ensure t
    :bind ("C-."   . embark-act))

(use-package embark-consult
    :ensure t
    :after (embark consult))

(use-package corfu
    :ensure t
    :custom
    (corfu-auto t)
    (corfu-cycle t)
    :init
    (global-corfu-mode)
    :config
    (corfu-popupinfo-mode))

;; ── Navigation & undo ─────────────────────────────────────────────────
;; Jump to any visible text by typing a few characters (Doom config/default).
(use-package avy
    :ensure t
    :bind ("C-'" . avy-goto-char-timer))

;; Visual undo tree (GNU ELPA; Doom emacs/undo, EWS) — makes Emacs's
;; undo/redo model legible instead of a mystery.
(use-package vundo
    :ensure t
    :bind ("C-x u" . vundo))

;; ── Icons ───────────────────────────────────────────────────────────
;; Glyphs in dired and minibuffer annotations only (Doom's +icons pair).
;; nerd-icons itself is a dependency of both, so it needs no block of its own.
(use-package nerd-icons-dired
    :ensure t
    :hook (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-completion
    :ensure t
    :after marginalia
    :config
    (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup)
    (nerd-icons-completion-mode))

;; ── Visual polish ─────────────────────────────────────────────────────
;; Emacs 30+ ships which-key in core, so
;; use the built-in (:ensure nil) instead of the MELPA copy — matches the
;; built-in preference already applied to org/eglot/project, and drops one
;; package from the Nix closure.
(use-package which-key
    :ensure nil
    :custom
    ;; Top, not bottom — same laptop ergonomics as vertico-posframe above.
    (which-key-side-window-location 'top)
    (which-key-side-window-max-height 0.25)
    :init (which-key-mode))

(use-package pulsar
    :ensure t
    :defer t
    ;; Purely cosmetic line-pulse on navigation — no need at first paint.
    :init (run-with-idle-timer 0.1 nil (lambda () (pulsar-global-mode 1))))

;; Prose only (EWS): centering code fought split windows and needed a pi
;; exemption. Elsewhere toggle by hand with M-x olivetti-mode.
(use-package olivetti
    :ensure t
    :custom (olivetti-body-width 100)
    :hook ((org-mode markdown-mode) . olivetti-mode))

;; ── pi (coding agent) ────────────────────────────────────────────────
;; Emacs frontend for the pi CLI. The `pi` binary is provided system-wide
;; via nix (@earendil-works/pi-coding-agent); the Emacs package only
;; needs to find it on PATH.
(use-package pi-coding-agent
    :ensure t
    :defer t
    :commands (pi-coding-agent)
    :init (defalias 'pi 'pi-coding-agent)
    :config
    ;; Grammars are provided by nix (treesit-grammars.with-all-grammars);
    ;; suppress the first-run install prompt. Set on load (not :custom) so this
    ;; on-demand agent isn't pulled into startup just to apply the setting.
    (setq pi-coding-agent-essential-grammar-action 'warn))

;; ── Git ───────────────────────────────────────────────────────────────
(use-package magit
    :ensure t
    :bind ("C-x g" . magit-status))

(use-package diff-hl
    :ensure t
    :defer t
    ;; pre-refresh became `ignore' in diff-hl 1.11 — post-refresh is enough.
    :hook (magit-post-refresh . diff-hl-magit-post-refresh)
    :init
    ;; Gutter VC markers only matter once you're in a file/magit buffer — bring
    ;; the global modes up just after the first frame, off the startup path.
    (run-with-idle-timer 0.1 nil (lambda () (require 'diff-hl)))
    :config
    (global-diff-hl-mode)
    (diff-hl-margin-mode))

;; ── LSP (eglot — built-in) ───────────────────────────────────────────
;; Auto-start for any language with an LSP server on $PATH.
;; sql-mode excluded — no reliable SQL LSP; formatting via sqlformat package.
(add-hook 'prog-mode-hook
    (lambda ()
        (unless (derived-mode-p 'sql-mode)
            (eglot-ensure))))
;; No envrc retry hook needed: eglot-ensure defers its connect to
;; post-command-hook, which runs after envrc has applied the devShell env
;; to the buffer (envrc-global-mode is enabled late in init so its
;; find-file hook runs first). If the devShell changes mid-session, run
;; M-x envrc-reload then M-x eglot-reconnect manually.

;; Format on save when an LSP is managing the buffer.
;; Buffer-local hook attached only to eglot-managed buffers — avoids
;; running the eglot check on every save in every buffer.
(add-hook 'eglot-managed-mode-hook
    (lambda ()
        (when (eglot-server-capable :documentFormattingProvider)
            (add-hook 'before-save-hook #'eglot-format-buffer nil t))))

;; Inlay hints off by default — toggle with C-c h
(add-hook 'eglot-managed-mode-hook (lambda () (eglot-inlay-hints-mode -1)))
(global-set-key (kbd "C-c h") #'eglot-inlay-hints-mode)

;; Subprocess I/O sized for LSP payloads (numpy/torch hovers are large):
;; 1 MB reads — minimal-emacs.d / Doom-LSP baseline. (Adaptive read
;; buffering is off by default since Emacs 31.)
(setq read-process-output-max (* 1024 1024))

;; Register LSP servers not built into eglot.
;; Python: `rass` (the global rassumfrassum multiplexer) fans out to ty + ruff,
;; which it spawns *by name* — so each project's devShell must put `ty` and
;; `ruff` on PATH. rass itself is a global editor tool, but a devShell rebuilds
;; PATH from its own inputs and drops the global profile, so a bare "rass" is
;; invisible inside one. Resolve rass's absolute path at init (before any direnv
;; shadowing) and launch that; rass still inherits the buffer's devShell PATH, so
;; it finds that project's ty + ruff. nil on hosts without rass, so the entry is
;; simply skipped (matches the old executable-find guard's intent).
(defvar tf/rass-program (executable-find "rass")
    "Absolute path to the global rass LSP multiplexer, resolved at startup.")

(with-eval-after-load 'eglot
    ;; No events log (Doom/minimal-emacs.d; Eglot manual, Performance), shut
    ;; servers down with their last buffer, don't block on connect (Prot).
    (setq eglot-events-buffer-config '(:size 0 :format short)
          eglot-autoshutdown t
          eglot-sync-connect nil)
    (when tf/rass-program
        (add-to-list 'eglot-server-programs
            `((python-mode python-ts-mode) . (,tf/rass-program "python")))))

;; ── Languages ─────────────────────────────────────────────────────────
(use-package markdown-mode
    :ensure t
    :mode ("\\.md\\'" . markdown-mode)
    :custom
    ;; Highlight fenced code blocks in their native major mode's font-lock.
    ;; Lighter than polymode/LSP — purely visual, no completion/indent.
    (markdown-fontify-code-blocks-natively t))

;; T-SQL as default SQL dialect
(setq sql-product 'ms)

(use-package sql-indent
    :ensure t
    :hook (sql-mode . sqlind-minor-mode))

(use-package sqlformat
    :ensure t
    :custom
    (sqlformat-command 'sql-formatter)
    ;; Same shared style file dprint and Zed use (deployed by dprint.nix) —
    ;; sql-formatter does not auto-discover it.
    (sqlformat-args (list "--language" "transactsql"
                        "--config" (expand-file-name "~/.config/sql-formatter/config.json")))
    :hook (sql-mode . sqlformat-on-save-mode))

(use-package nix-mode
    :ensure t
    :mode "\\.nix\\'"
    :hook (nix-mode . (lambda () (setq-local tab-width 2))))

;; Haskell. haskell-indentation-mode handles the language's layout rule;
;; eglot auto-attaches to haskell-language-server when a devShell provides it.
(use-package haskell-mode
    :ensure t
    :mode "\\.hs\\'"
    :hook (haskell-mode . haskell-indentation-mode))

;; Emacs 30 ships editorconfig in core — built-in (:ensure nil), same as
;; which-key; the MELPA copy was shadowing it.
(use-package editorconfig
    :ensure nil
    :init (editorconfig-mode 1))

;; Tree-sitter modes. Every built-in ts mode registers itself in
;; `treesit-major-mode-remap-alist' (Emacs 31); `t' remaps them all into
;; `major-mode-remap-alist' (yaml-ts-mode adds its own auto-mode entry).
;; Grammars come from Nix (emacs.nix), so never offer to build one.
(setopt treesit-enabled-modes t
        treesit-auto-install-grammar 'never)

;; Fontify at the richest level — adds variables, function-call names,
;; operators, brackets, and delimiters (the default 3 leaves these the
;; plain foreground, which reads as "lots of white").
(setopt treesit-font-lock-level 4)

;; Python. eglot + rass attach via the prog-mode hook above; envrc puts the
;; project's .venv python first on exec-path, so M-x compile and run-python
;; (C-c C-p) both use it. Course drivers are plain `python main.py' entry
;; points (what Gradescope runs), so make that the default compile-command:
;; M-x compile / C-x p c is one keystroke, compilation-mode parses the
;; traceback, M-g M-n jumps to the failing line, `g' re-runs.
(add-hook 'python-base-mode-hook
    (lambda () (setq-local compile-command "python main.py")))
;; Follow output until the first error, then stop there (newcomers-presets).
(setq compilation-scroll-output 'first-error)

;; ── Org ───────────────────────────────────────────────────────────────
;; %(sexp) helper for the assignment template: a titled link for the URL on
;; the clipboard (Canvas/Gradescope), else nothing — bare org-cliplink-capture
;; wraps any non-URL clipboard text in [[...]] and errors on an empty kill ring.
(defun tf/org-capture-cliplink ()
    "Titled org link for a URL on the clipboard, else an empty string."
    (let ((clip (ignore-errors (string-trim (current-kill 0)))))
        (if (and clip (string-match-p "\\`https?://" clip))
            (org-cliplink-capture)
            "")))

(use-package org
    :ensure nil
    ;; Org's parser hard-requires tab-width 8 (global default is 4).
    ;; editorconfig enforces this for file-backed .org via `[*.org]
    ;; tab_width = 8'; this hook covers non-file org buffers (capture,
    ;; agenda) that editorconfig skips. editorconfig-exclude-modes is a
    ;; no-op in the 2026 editorconfig rewrite, so we set 8 rather than
    ;; trying to exempt org.
    :hook (org-mode . (lambda () (setq-local tab-width 8)))
    :bind (("C-c c" . org-capture)
              ("C-c a" . org-agenda)
              ("C-c l" . org-store-link)
              ;; org takes C-' for org-cycle-agenda-files; keep it for avy.
              (:map org-mode-map ("C-'" . nil)))
    :custom
    (org-directory "~/Documents/notes")
    ;; Directory form (Prot; Doom's default): every top-level .org file in
    ;; org-directory is an agenda file — CS7637.org, todo.org, inbox.org —
    ;; with nothing to keep in sync when a file is added.
    (org-agenda-files (list org-directory))
    (org-startup-indented t)
    ;; Visible markers (Prot): hidden *bold*/=code= delimiters are the classic
    ;; "why can't I edit this" trap; org-appear is the alternative if wanted.
    (org-hide-emphasis-markers nil)
    (org-log-done 'time)
    (org-return-follows-link t)
    (org-fold-catch-invisible-edits 'show-and-error)
    (org-id-link-to-org-use-id 'create-if-interactive)
    (org-id-locations-file
        (expand-file-name ".org-id-locations" org-directory))
    (org-time-stamp-custom-formats '("<%Y-%m-%d>" . "<%Y-%m-%d %H:%M>"))
    ;; Refile: vertico-powered flat completion across org files
    (org-refile-targets '((org-agenda-files :maxlevel . 2)))
    (org-refile-use-outline-path 'file)
    (org-outline-path-complete-in-steps nil)
    ;; C-c a w: the week (Monday start) with deadlines 14 days out — OMSCS
    ;; posts milestones about two weeks ahead — then every undated TODO.
    (org-agenda-custom-commands
        '(("w" "Week"
              ((agenda "" ((org-agenda-span 'week)
                           (org-agenda-start-on-weekday 1)
                           (org-deadline-warning-days 14)))
               (todo "TODO" ((org-agenda-overriding-header "Unscheduled")
                             (org-agenda-todo-ignore-deadlines 'all)
                             (org-agenda-todo-ignore-scheduled 'all)))))))
    :config
    ;; Capture first, refile later (C-c C-w; targets reach level-2 lesson
    ;; headings) — the GTD consensus and the lowest-friction path. Course
    ;; notes and deadlines share CS7637.org so a lesson and its milestone
    ;; live in one file; todo.org stays household. Missing target headlines
    ;; are created at the end of the file on first use.
    (setq org-capture-templates
        '(("n" "Lecture note" entry (file+headline "CS7637.org" "Inbox")
              "* %?\n%U\n")
          ("a" "Assignment" entry (file+headline "CS7637.org" "Assignments")
              "* TODO %^{Assignment}\nDEADLINE: %^{Due}t\n%U\n%(tf/org-capture-cliplink)\n%?")
          ("i" "Inbox" entry (file "inbox.org")
              "* %?\n%U\n")
          ("t" "Task" entry (file+headline "todo.org" "Inbox")
              "* TODO %?\n%U\n"))))

;; Startup surface: the week agenda ("what is due"), not a portal of recent
;; files. Only consulted when Emacs starts without file arguments.
(setq initial-buffer-choice
    (lambda () (org-agenda nil "w") (get-buffer "*Org Agenda*")))

(use-package org-cliplink
    :ensure t
    :bind ("C-c n l" . org-cliplink))

;; ── PDF ───────────────────────────────────────────────────────────────
;; Course readings in-Emacs. doc-view can't work here (no mutool/gs/pdftoppm
;; on PATH); pdf-tools ships its own epdfinfo server, built by nixpkgs.
(use-package pdf-tools
    :ensure t
    :mode ("\\.pdf\\'" . pdf-view-mode)
    :config (pdf-tools-install :no-query))

;; ── TRAMP ─────────────────────────────────────────────────────────────
(setq tramp-default-method "ssh")

;; ── Direnv ────────────────────────────────────────────────────────────
(use-package envrc
    :ensure t
    :init (envrc-global-mode))

;; ── Dired ────────────────────────────────────────────────────────────
(setq delete-by-moving-to-trash t
      dired-dwim-target t
      dired-auto-revert-buffer t)
(add-hook 'dired-mode-hook #'dired-hide-details-mode)

;; ── Terminal ──────────────────────────────────────────────────────────
;; vterm only — Nix compiles the libvterm module at build time. Built-in
;; eshell stays available with its defaults for quick Lisp-aware work.
(use-package vterm
    :ensure t
    :commands vterm
    :config
    (setq vterm-max-scrollback 10000))

;; ── Misc ──────────────────────────────────────────────────────────────
(add-to-list 'vc-directory-exclusion-list ".jj")

;; Register known project trees (deferred to avoid slowing startup)
(require 'project)
(setq project-switch-commands
    '((magit-project-status "Magit" "m")
         (project-find-file "Find file" "f")
         (project-find-dir "Find dir" "d")
         (project-eshell "Eshell" "e")
         (consult-ripgrep "Ripgrep" "r")))
(add-hook 'emacs-startup-hook
    (lambda ()
        (project-remember-projects-under "~/Projects/")
        (dolist (dir '("~/nix-config/"
                          "~/Documents/notes/"
                          "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/"))
            (when (file-directory-p dir)
                (project-remember-project (project-current nil dir))))))

;; ── Server ──────────────────────────────────────────────────────────
;; macOS has no launchd daemon (see modules/shared/home/emacs.nix): the GUI
;; Emacs.app you launch from your session is the canonical server, so start it
;; here. On NixOS the systemd `emacs --daemon' already runs a server (and
;; `daemonp' is non-nil), so skip there to avoid a double-start.
(when (and (eq system-type 'darwin) (not (daemonp)))
    (require 'server)
    (unless (server-running-p) (server-start)))

;;; init.el ends here
