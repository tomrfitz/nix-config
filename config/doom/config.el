;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Thomas FitzGerald"
      user-mail-address "tomrfitz@gmail.com")

;; ── Appearance ──────────────────────────────────────────────────────────
;; GUI: use flexoki theme. Terminal: defer to Ghostty's ANSI palette.
(setq doom-theme (if (display-graphic-p) 'flexoki-themes-dark nil)
      doom-font (font-spec :family "Atkinson Hyperlegible Mono" :size 14)
      doom-variable-pitch-font (font-spec :family "Atkinson Hyperlegible" :size 14)
      display-line-numbers-type 'relative)

;; ── Org ─────────────────────────────────────────────────────────────────
(setq org-directory "~/notes/")
