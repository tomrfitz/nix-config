;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

;; ── Package bootstrap ─────────────────────────────────────────────────
(require 'package)

(setq package-archives '(("melpa"  . "https://melpa.org/packages/")
                            ("gnu"    . "https://elpa.gnu.org/packages/")
                            ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

(package-initialize)

;; Install missing packages up front (first launch pulls from network).
(let ((packages '(vertico orderless marginalia consult consult-dir
                     embark embark-consult corfu cape which-key pulsar
                     exec-path-from-shell spacious-padding olivetti mini-frame
                     magit diff-hl nix-mode markdown-mode treesit-auto
                     org-cliplink org-appear envrc editorconfig dashboard
                     nerd-icons nerd-icons-dired nerd-icons-corfu
                     nerd-icons-completion sqlformat sql-indent
                     gcmh avy vundo helpful undo-fu-session
                     string-inflection eat jinx)))
    (let ((missing (cl-remove-if #'package-installed-p packages)))
        (when missing
            (package-refresh-contents)
            (dolist (pkg missing)
                (package-install pkg)))))

(setq use-package-always-ensure t
      use-package-expand-minimally t)

(use-package gcmh
    :init (gcmh-mode)
    :custom
    (gcmh-idle-delay 'auto)
    (gcmh-high-cons-threshold (* 64 1024 1024)))

;; ── Shell environment ───────────────────────────────────────────────
;; macOS GUI Emacs doesn't inherit shell PATH — sync it from login shell
(use-package exec-path-from-shell
    :if (eq window-system 'ns)
    :init (exec-path-from-shell-initialize))

;; ── Identity ──────────────────────────────────────────────────────────
(setq user-full-name "Thomas FitzGerald"
    user-mail-address "tomrfitz@gmail.com")

;; ── Sane defaults ─────────────────────────────────────────────────────
(delete-selection-mode 1)
(repeat-mode 1)
(setq savehist-additional-variables
    '(kill-ring register-alist mark-ring global-mark-ring))
(savehist-mode 1)
(setq recentf-exclude '("elpa/" "\\`/tmp/" "\\`/ssh:" "\\.elc\\'" "COMMIT_EDITMSG"))
(recentf-mode 1)
(save-place-mode 1)
(global-auto-revert-mode 1)
(global-so-long-mode 1)
(global-goto-address-mode 1)
(winner-mode 1)
(pixel-scroll-precision-mode 1)
;; Prevent trackpad/scroll-wheel from triggering text-scale changes
(global-set-key (kbd "<pinch>") 'ignore)
(global-set-key (kbd "<C-wheel-up>") 'ignore)
(global-set-key (kbd "<C-wheel-down>") 'ignore)
(column-number-mode 1)
(global-display-line-numbers-mode 1)
(setq-default display-line-numbers-width-start t
              display-line-numbers-grow-only t)
(show-paren-mode 1)

(setq use-short-answers t
    confirm-kill-emacs nil
    create-lockfiles nil
    make-backup-files nil
    custom-file (expand-file-name "custom.el" user-emacs-directory)
    completion-ignore-case t
    read-buffer-completion-ignore-case t
    read-file-name-completion-ignore-case t
    kill-do-not-save-duplicates t
    ring-bell-function #'ignore
    calendar-week-start-day 1
    calendar-date-style 'iso
    scroll-conservatively 101
    scroll-margin 0)

;; Subprocess I/O (critical for eglot/LSP performance)
(setq read-process-output-max (* 4 1024 1024)
      process-adaptive-read-buffering nil)

;; File/buffer behavior
(setq global-auto-revert-non-file-buffers t
      dired-auto-revert-buffer t
      vc-follow-symlinks t
      find-file-visit-truename t
      switch-to-buffer-obey-display-actions t
      bookmark-save-flag 1
      tramp-verbose 1)

;; Display
(setq x-underline-at-descent-line t
      truncate-string-ellipsis "\u2026"
      pixel-scroll-precision-use-momentum nil)

;; Minibuffer
(setq enable-recursive-minibuffers t)
(file-name-shadow-mode 1)

;; Ediff in same frame
(setq ediff-window-setup-function #'ediff-setup-windows-plain)

;; xref via ripgrep + vertico
(setq xref-show-definitions-function #'xref-show-definitions-completing-read
      xref-search-program 'ripgrep)

;; Auto-chmod scripts on save
(add-hook 'after-save-hook #'executable-make-buffer-file-executable-if-script-p)

;; Tame popup buffers
(setq display-buffer-alist
    '(("\\*\\(Help\\|Warnings\\|Backtrace\\|Compile-Log\\|Flymake diagnostics\\|eldoc.*\\)\\*"
       (display-buffer-in-side-window)
       (window-height . 0.25)
       (side . bottom))))

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

;; ── Frame ───────────────────────────────────────────────────────────
(when (eq system-type 'darwin)
    (add-to-list 'default-frame-alist '(undecorated-round . t)))

;; ── Theme ─────────────────────────────────────────────────────────────
;; Local Flexoki theme (spec-corrected); platform-aware dark/light switching.
(let ((themes-dir (expand-file-name "themes/" user-emacs-directory)))
    (add-to-list 'custom-theme-load-path themes-dir)
    (add-to-list 'load-path themes-dir))

(defun tf/apply-theme (appearance)
    "Load the appropriate Flexoki variant for APPEARANCE (`light' or `dark')."
    (mapc #'disable-theme custom-enabled-themes)
    (pcase appearance
        ('light (load-theme 'flexoki-light t))
        ('dark  (load-theme 'flexoki-dark t))))

(cond
    ;; macOS: instant switching via emacs-plus hook
    ((eq system-type 'darwin)
        (add-hook 'ns-system-appearance-change-functions #'tf/apply-theme)
        (tf/apply-theme ns-system-appearance))
    ;; Linux: noctalia theme if available, flexoki-dark fallback
    ((eq system-type 'gnu/linux)
        (let ((noctalia-dir (expand-file-name "themes/" user-emacs-directory)))
            (if (file-directory-p noctalia-dir)
                (progn
                    (add-to-list 'custom-theme-load-path noctalia-dir)
                    (load-theme 'noctalia t))
                (load-theme 'flexoki-dark t))))
    ;; Fallback
    (t (load-theme 'flexoki-dark t)))

;; ── Completion ────────────────────────────────────────────────────────
(use-package vertico
    :init (vertico-mode)
    :bind (:map vertico-map
           ("RET"   . vertico-directory-enter)
           ("DEL"   . vertico-directory-delete-char)
           ("M-DEL" . vertico-directory-delete-word))
    :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package orderless
    :custom
    (completion-styles '(orderless basic))
    (completion-category-overrides
     '((file (styles partial-completion))
       (eglot (styles orderless basic))
       (eglot-capf (styles orderless basic)))))

(use-package marginalia
    :init (marginalia-mode))

(use-package consult
    :bind (("C-x b"   . consult-buffer)
           ("C-x r b" . consult-bookmark)
           ("M-g g"   . consult-goto-line)
           ("M-g M-g" . consult-goto-line)
           ("M-s l"   . consult-line)
           ("M-s r"   . consult-ripgrep)
           ("M-s f"   . consult-find))
    :config
    ;; Disable auto-preview for heavy commands (M-P to preview manually)
    (consult-customize
     consult-ripgrep consult-grep consult-git-grep
     consult-bookmark consult-recent-file
     :preview-key "M-P")
    ;; Push mark before grep jumps so M-, returns
    (advice-add 'consult-ripgrep :before
        (lambda (&rest _) (xref-push-marker-stack))))

(use-package embark
    :bind ("C-." . embark-act)
    :custom (prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
    :after (embark consult))

(use-package consult-dir
    :bind (("C-x C-d" . consult-dir)
           :map vertico-map
           ("C-x C-d" . consult-dir)))

(use-package corfu
    :custom
    (corfu-auto t)
    (corfu-cycle t)
    :bind (:map corfu-map
           ("RET" . nil)
           ("M-RET" . corfu-insert))
    :init
    (global-corfu-mode)
    (corfu-popupinfo-mode))

;; ── Icons ───────────────────────────────────────────────────────────
(use-package nerd-icons)

(use-package nerd-icons-dired
    :hook (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-corfu
    :after corfu
    :config
    (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package cape
    :after corfu
    :init
    (add-hook 'completion-at-point-functions #'cape-file)
    (add-hook 'completion-at-point-functions #'cape-dabbrev)
    (add-hook 'completion-at-point-functions #'cape-elisp-block)
    :config
    ;; Bust eglot completion cache for fresh results
    (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster))

(when (>= emacs-major-version 30)
    (global-completion-preview-mode)
    ;; Disable in corfu to avoid conflict
    (add-hook 'corfu-mode-hook
        (lambda () (completion-preview-mode (if corfu-mode -1 1)))))

(use-package nerd-icons-completion
    :after marginalia
    :config
    (nerd-icons-completion-mode)
    (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

;; ── Visual polish ─────────────────────────────────────────────────────
(use-package dashboard
    :custom
    (dashboard-display-icons-p t)
    (dashboard-icon-type 'nerd-icons)
    (dashboard-set-file-icons t)
    (dashboard-set-heading-icons t)
    (dashboard-items '((recents . 10)
                          (projects . 5)
                          (bookmarks . 5)))
    (dashboard-startup-banner 'ascii)
    (dashboard-center-content t)
    :config
    (dashboard-setup-startup-hook))

(use-package which-key
    :custom
    (which-key-side-window-location 'bottom)
    (which-key-side-window-max-height 0.25)
    :init (which-key-mode))

(use-package pulsar
    :init (pulsar-global-mode))

(use-package spacious-padding
    :init (spacious-padding-mode))


(use-package olivetti
    :custom (olivetti-body-width 88)
    :hook ((prog-mode text-mode) . olivetti-mode))

(use-package mini-frame
    :if (display-graphic-p)
    :custom
    (mini-frame-show-parameters
        '((top . 0)
             (left . 0.5)
             (width . 0.8)
             (height . 1)
             (child-frame-border-width . 1)))
    (mini-frame-detach-on-hide nil)
    :init (mini-frame-mode))

;; ── Git ───────────────────────────────────────────────────────────────
(use-package magit
    :bind ("C-x g" . magit-status)
    :custom
    (magit-log-margin '(t "%Y-%m-%d %H:%M " magit-log-margin-width t 18))
    (magit-diff-refine-hunk t)
    (magit-section-initial-visibility-alist '((untracked . hide))))

(use-package diff-hl
    :hook ((magit-pre-refresh  . diff-hl-magit-pre-refresh)
           (magit-post-refresh . diff-hl-magit-post-refresh))
    :init
    (global-diff-hl-mode)
    (diff-hl-margin-mode))

;; ── LSP (eglot — built-in) ───────────────────────────────────────────
(setq eglot-autoshutdown t
      eglot-sync-connect 0
      eglot-extend-to-xref t
      eglot-events-buffer-config '(:size 0 :format short))
(setq jsonrpc-event-hook nil)  ; eliminate logging overhead
(setq eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)

;; Auto-start for any language with an LSP server on $PATH.
;; sql-mode/emacs-lisp-mode excluded — no useful LSP for either.
(add-hook 'prog-mode-hook
    (lambda ()
        (unless (derived-mode-p 'sql-mode 'emacs-lisp-mode)
            (eglot-ensure))))
;; Retry after envrc injects the direnv PATH — catches devShell LSPs
;; (sqls, ruff, etc.) that weren't on PATH when prog-mode-hook ran.
(add-hook 'envrc-after-update-hook
    (lambda ()
        (when (derived-mode-p 'prog-mode)
            (eglot-ensure))))

;; Format on save when an LSP is managing the buffer
(add-hook 'before-save-hook
    (lambda ()
        (when (and (eglot-managed-p)
                  (eglot--server-capable :documentFormattingProvider))
            (eglot-format-buffer))))

;; Inlay hints off by default — toggle with C-c h
(add-hook 'eglot-managed-mode-hook (lambda () (eglot-inlay-hints-mode -1)))
(global-set-key (kbd "C-c h") #'eglot-inlay-hints-mode)

;; Register LSP servers not built into eglot
(with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs '((java-mode java-ts-mode) . ("jdtls")))
    ;; Python: rass multiplexes ty (type checker) + ruff (linter/formatter)
    ;; Falls back gracefully — only errors if rass/ty/ruff missing when eglot starts
    (add-to-list 'eglot-server-programs '((python-mode python-ts-mode) . ("rass" "python")))
)

;; ── Languages ─────────────────────────────────────────────────────────
(use-package markdown-mode
    :mode ("\\.md\\'" . markdown-mode)
    :hook (markdown-mode . (lambda ()
                               (add-hook 'after-save-hook
                                   (lambda ()
                                       (when (and buffer-file-name
                                                 (executable-find "markdownlint-cli2"))
                                           (call-process "markdownlint-cli2" nil nil nil "--fix" buffer-file-name)
                                           (revert-buffer t t t)))
                                   nil t))))

;; T-SQL as default SQL dialect
(setq sql-product 'ms)

(use-package sql-indent
    :hook (sql-mode . sqlind-minor-mode))

(use-package sqlformat
    :custom
    (sqlformat-command 'sql-formatter)
    (sqlformat-args '("--language" "transactsql"))
    :hook (sql-mode . sqlformat-on-save-mode))

(use-package nix-mode
    :mode "\\.nix\\'"
    :hook (nix-mode . (lambda () (setq-local tab-width 2))))

;; visual-basic-mode: not on MELPA/ELPA and has malformed version header,
;; so package-vc-install fails. Download the .el directly on first use.
(let ((vb-file (expand-file-name "lisp/visual-basic-mode.el" user-emacs-directory)))
    (unless (file-exists-p vb-file)
        (make-directory (file-name-directory vb-file) t)
        (url-copy-file
            "https://raw.githubusercontent.com/emacsmirror/visual-basic-mode/master/visual-basic-mode.el"
            vb-file))
    (when (file-exists-p vb-file)
        (add-to-list 'load-path (file-name-directory vb-file))
        (autoload 'visual-basic-mode "visual-basic-mode" "Visual Basic mode." t)
        (add-to-list 'auto-mode-alist '("\\.\\(bas\\|cls\\|frm\\)\\'" . visual-basic-mode))))

(use-package editorconfig
    :init (editorconfig-mode 1))

(use-package treesit-auto
    :custom (treesit-auto-install 'prompt)
    :config (global-treesit-auto-mode))

;; ── Org ───────────────────────────────────────────────────────────────
(use-package org
    :ensure nil
    :bind (("C-c c" . org-capture)
              ("C-c a" . org-agenda)
              ("C-c l" . org-store-link))
    :custom
    (org-directory "~/Documents/notes")
    (org-agenda-files '("~/Documents/notes/inbox.org"
                           "~/Documents/notes/todo.org"))
    (org-startup-indented t)
    (org-hide-emphasis-markers t)
    (org-log-done 'time)
    (org-return-follows-link t)
    (org-catch-invisible-edits 'show-and-error)
    (org-id-link-to-org-use-id 'create-if-interactive)
    (org-id-locations-file
        (expand-file-name ".org-id-locations" org-directory))
    (org-time-stamp-custom-formats '("<%Y-%m-%d>" . "<%Y-%m-%d %H:%M>"))
    (org-use-speed-commands t)
    (org-special-ctrl-a/e '(t . t))
    (org-ellipsis " \u25be ")
    (org-refile-use-cache t)
    (org-refile-allow-creating-parent-nodes 'confirm)
    (org-M-RET-may-split-line '((headline) (default . nil)))
    (org-use-sub-superscripts '{})
    (org-list-demote-modify-bullet '(("+" . "-") ("-" . "+") ("*" . "+")))
    ;; Refile: vertico-powered flat completion across org files
    (org-refile-targets '((org-agenda-files :maxlevel . 2)))
    (org-refile-use-outline-path 'file)
    (org-outline-path-complete-in-steps nil)
    :config
    (setq org-capture-templates
        `(("i" "Inbox" entry (file "inbox.org")
              "* %?\n%U\n")
             ("t" "Task" entry (file+headline "todo.org" "Inbox")
                 "* TODO %?\n%U\n")
             ("j" "Journal" entry
                 (file ,(format "journal/%s.org"
                            (format-time-string "%Y-%m-%d")))
                 "* %<%H:%M> %?\n")
             ("r" "Reference" entry (file "inbox.org")
                 "* %^{Title}\n%U\n%^{URL}\n\n%?"))))

(use-package org-cliplink
    :bind ("C-c n l" . org-cliplink))

(custom-set-faces
 '(outline-1 ((t (:weight extra-bold :height 1.25))))
 '(outline-2 ((t (:weight bold :height 1.15))))
 '(outline-3 ((t (:weight bold :height 1.12))))
 '(outline-4 ((t (:weight semi-bold :height 1.09))))
 '(outline-5 ((t (:weight semi-bold :height 1.06))))
 '(outline-6 ((t (:weight semi-bold :height 1.03)))))

(use-package org-appear
    :hook (org-mode . org-appear-mode)
    :custom (org-appear-autoemphasis t))

(defun tf/defer-font-lock-in-large-buffers ()
    (when (> (buffer-size) 50000)
        (setq-local jit-lock-defer-time 0.05
                    jit-lock-stealth-time 1)))
(add-hook 'org-mode-hook #'tf/defer-font-lock-in-large-buffers)

;; ── TRAMP ─────────────────────────────────────────────────────────────
(setq tramp-default-method "ssh")

;; ── Direnv ────────────────────────────────────────────────────────────
(use-package envrc
    :init (envrc-global-mode))

;; ── Dired ────────────────────────────────────────────────────────────
(setq delete-by-moving-to-trash t
      dired-dwim-target t)
(add-hook 'dired-mode-hook #'dired-hide-details-mode)

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
        (project-remember-projects-under "~/Developer/")
        (dolist (dir '("~/nix-config/"
                          "~/Documents/notes/"
                          "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/"))
            (when (file-directory-p dir)
                (project-remember-project (project-current nil dir))))))

;; ── Navigation ──────────────────────────────────────────────────────
(use-package avy
    :bind (("C-'"   . avy-goto-char-timer)
           ("M-g w" . avy-goto-word-1)
           ("M-g l" . avy-goto-line))
    :custom
    (avy-all-windows t)
    (avy-styles-alist '((avy-goto-char-timer . post)
                         (avy-goto-line . pre))))

;; ── Undo ────────────────────────────────────────────────────────────
(use-package vundo
    :bind ("C-x u" . vundo))

(use-package undo-fu-session
    :hook ((prog-mode conf-mode text-mode) . undo-fu-session-mode))

;; ── Help ────────────────────────────────────────────────────────────
(use-package helpful
    :bind (("C-h f" . helpful-callable)
           ("C-h v" . helpful-variable)
           ("C-h k" . helpful-key)
           ("C-h x" . helpful-command)))

;; ── Editing ─────────────────────────────────────────────────────────
(use-package string-inflection
    :bind ("C-c i" . string-inflection-all-cycle))

;; ── Terminal ────────────────────────────────────────────────────────
(use-package eat
    :bind ("C-c t" . eat))

;; ── Spellcheck ──────────────────────────────────────────────────────
(use-package jinx
    :hook ((text-mode prog-mode conf-mode) . jinx-mode)
    :bind ("M-$" . jinx-correct))

;; ── Utility functions ───────────────────────────────────────────────
;; Smarter C-g: deactivate region → close minibuffer → quit
(defun tf/keyboard-quit-dwim ()
    (interactive)
    (cond
     ((region-active-p) (keyboard-quit))
     ((derived-mode-p 'completion-list-mode) (delete-completion-window))
     ((> (minibuffer-depth) 0) (abort-recursive-edit))
     (t (keyboard-quit))))
(global-set-key [remap keyboard-quit] #'tf/keyboard-quit-dwim)

;; C-a toggles between indentation and column 0
(defun tf/beginning-of-line-or-indentation ()
    (interactive "^")
    (let ((orig (point)))
        (back-to-indentation)
        (when (= orig (point))
            (beginning-of-line))))
(global-set-key [remap move-beginning-of-line] #'tf/beginning-of-line-or-indentation)

;; C-x 1 toggles: delete-other-windows ↔ winner-undo
(defun tf/toggle-delete-other-windows ()
    (interactive)
    (if (and winner-mode (equal (selected-window) (next-window)))
        (winner-undo)
        (delete-other-windows)))
(global-set-key [remap delete-other-windows] #'tf/toggle-delete-other-windows)

;; Single binding for all narrowing: widen if narrowed, narrow to region/subtree/defun
(defun tf/narrow-or-widen-dwim ()
    (interactive)
    (cond
     ((buffer-narrowed-p) (widen))
     ((region-active-p) (narrow-to-region (region-beginning) (region-end)))
     ((derived-mode-p 'org-mode) (org-narrow-to-subtree))
     ((derived-mode-p 'prog-mode) (narrow-to-defun))
     (t (widen))))
(global-set-key (kbd "C-x n") #'tf/narrow-or-widen-dwim)

;; Open line below/above (vim-like o/O)
(defun tf/open-line-below ()
    (interactive)
    (end-of-line)
    (newline-and-indent))
(defun tf/open-line-above ()
    (interactive)
    (beginning-of-line)
    (newline)
    (forward-line -1)
    (indent-for-tab-command))
(global-set-key (kbd "M-o")   #'tf/open-line-below)
(global-set-key (kbd "M-O")   #'tf/open-line-above)

;; find-file with line:column parsing (file.js:14:10)
(advice-add 'find-file :around
    (lambda (orig filename &optional wildcards)
        (let* ((matched (string-match "^\\(.*?\\):\\([0-9]+\\):?\\([0-9]*\\)$" filename))
               (line (and matched (match-string 2 filename)
                          (string-to-number (match-string 2 filename))))
               (col (and matched (match-string 3 filename)
                         (let ((c (string-to-number (match-string 3 filename)))) (and (> c 0) c))))
               (filename (if matched (match-string 1 filename) filename)))
            (funcall orig filename wildcards)
            (when line (goto-char (point-min)) (forward-line (1- line)))
            (when col (forward-char (1- col))))))

;; Save all buffers on focus loss
(add-function :after after-focus-change-function
    (lambda () (save-some-buffers t)))

;; Disable VC for remote files (prevents TRAMP hangs)
(add-hook 'find-file-hook
    (lambda ()
        (when (and buffer-file-name (file-remote-p buffer-file-name))
            (setq-local vc-handled-backends nil))))

;; ── Server ──────────────────────────────────────────────────────────
;; Start server when launched normally (not as --daemon, which has its own).
;; Delete stale socket first so emacsclient (and with-editor) always connect.
(unless (daemonp)
    (setq server-name "server")
    (when (server-running-p) (server-force-delete))
    (server-start))

;; Cmd-Q closes the frame, not Emacs — keeps the server alive for emacsclient.
;; Use M-x kill-emacs to actually quit.
(defun tf/close-frame ()
    "Close the current frame. If it's the last visible one, hide it to keep the server alive."
    (interactive)
    (let ((visible (cl-count-if #'frame-visible-p (frame-list))))
        (if (> visible 1)
            (delete-frame)
            (make-frame-invisible nil t))))

(when (eq system-type 'darwin)
    (global-set-key (kbd "s-q") #'tf/close-frame))

;;; init.el ends here
