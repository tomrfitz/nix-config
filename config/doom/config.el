;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Thomas FitzGerald"
      user-mail-address "tomrfitz@gmail.com")

;; ── Appearance ──────────────────────────────────────────────────────────
;; Noctalia generates theme on Linux; fall back to Flexoki on macOS/terminal.
(setq doom-font (font-spec :family "Atkinson Hyperlegible Mono" :size 14)
      doom-variable-pitch-font (font-spec :family "Atkinson Hyperlegible" :size 14)
      display-line-numbers-type 'relative)

(let ((noctalia-dir "~/.config/emacs/themes/"))
  (if (file-directory-p noctalia-dir)
      (progn
        (add-to-list 'custom-theme-load-path noctalia-dir)
        (setq doom-theme 'noctalia))
    (setq doom-theme (if (display-graphic-p) 'flexoki-themes-dark nil))))

;; ── Org ─────────────────────────────────────────────────────────────────
(setq org-directory "~/notes/")
