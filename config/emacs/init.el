;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

;; ── Package bootstrap ─────────────────────────────────────────────────
(require 'package)

(setq package-archives '(("melpa"  . "https://melpa.org/packages/")
                            ("gnu"    . "https://elpa.gnu.org/packages/")
                            ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

(package-initialize)

;; Install missing packages up front (first launch pulls from network).
(let ((packages '(vertico orderless marginalia consult
                     embark embark-consult corfu which-key pulsar
                     exec-path-from-shell spacious-padding olivetti mini-frame
                     magit nix-mode markdown-mode treesit-auto
                     org-cliplink envrc editorconfig dashboard
                     nerd-icons nerd-icons-dired nerd-icons-corfu
                     nerd-icons-completion)))
    (let ((missing (cl-remove-if #'package-installed-p packages)))
        (when missing
            (package-refresh-contents)
            (dolist (pkg missing)
                (package-install pkg)))))

(setq use-package-always-ensure t)

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
(savehist-mode 1)
(recentf-mode 1)
(save-place-mode 1)
(global-auto-revert-mode 1)
(global-so-long-mode 1)
(global-goto-address-mode 1)
(winner-mode 1)
(pixel-scroll-precision-mode 1)
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
    :init (vertico-mode))

(use-package orderless
    :custom
    (completion-styles '(orderless basic))
    (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
    :init (marginalia-mode))

(use-package consult
    :bind (("C-x b"   . consult-buffer)
              ("C-x r b" . consult-bookmark)
              ("M-g g"   . consult-goto-line)
              ("M-g M-g" . consult-goto-line)
              ("M-s l"   . consult-line)
              ("M-s r"   . consult-ripgrep)
              ("M-s f"   . consult-find)))

(use-package embark
    :bind ("C-."   . embark-act))

(use-package embark-consult
    :after (embark consult))

(use-package corfu
    :custom
    (corfu-auto t)
    (corfu-cycle t)
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

;; Modeline at top — swap header-line and mode-line
(setq-default header-line-format mode-line-format
    mode-line-format nil)
;; Info-mode uses header-line by default; move it to the (now-empty) mode-line
(with-eval-after-load 'info
    (add-hook 'Info-mode-hook
        (lambda ()
            (setq-local mode-line-format header-line-format
                header-line-format nil))))

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
    :bind ("C-x g" . magit-status))

;; ── LSP (eglot — built-in) ───────────────────────────────────────────
;; Auto-starts for any language with an LSP server on $PATH
;; (discovered via envrc/direnv from devShells).
(add-hook 'prog-mode-hook #'eglot-ensure)

;; Format on save when an LSP is managing the buffer
(add-hook 'before-save-hook
    (lambda ()
        (when (and (eglot-managed-p)
                  (eglot--server-capable :documentFormattingProvider))
            (eglot-format-buffer))))

;; Register LSP servers not built into eglot
(with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs '((java-mode java-ts-mode) . ("jdtls"))))

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

(use-package nix-mode
    :mode "\\.nix\\'"
    :hook (nix-mode . (lambda () (setq-local tab-width 2))))

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
(add-hook 'emacs-startup-hook
    (lambda ()
        (dolist (dir '("~/nix-config/"
                          "~/Developer/CSC204/"
                          "~/Developer/CSC331/"
                          "~/Developer/CS2A/"
                          "~/Developer/CS1332xI/"
                          "~/Documents/notes/"
                          "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/"))
            (when (file-directory-p dir)
                (project-remember-project (project-current nil dir))))))

;; ── Server ──────────────────────────────────────────────────────────
;; Start server when launched normally (not as --daemon, which has its own).
(unless (daemonp)
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
