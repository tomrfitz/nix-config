;;; flexoki.el --- Flexoki color theme (spec-corrected) -*- lexical-binding: t; -*-

;; Palette and face definitions for the Flexoki colour scheme by Steph Ango.
;; Syntax mappings corrected to match the official spec and Helix tree-sitter
;; theme, with Emacs 29+ font-lock faces for tree-sitter modes.
;;
;; Upstream Emacs port: https://codeberg.org/crmsnbleyd/flexoki-emacs-theme
;; Official spec:       https://stephango.com/flexoki
;; Helix reference:     runtime/themes/flexoki_{dark,light}.toml
;; Zed reference:       https://github.com/kepano/flexoki/tree/main/zed
;;
;; ── Changes from upstream (crmsnbleyd/flexoki-emacs-theme v0.20) ────
;;
;; Palette fixes:
;;   - Neutral scale uses full spec (n-50 through n-950, not just 6 greys)
;;   - Semantic neutrals (bg, bg-2, ui, ui-2, ui-3, tx, tx-2, tx-3) follow
;;     the official spec mapping — upstream had tx-2/tx-3 swapped between
;;     light and dark variants
;;
;; Font-lock corrections (spec + Helix alignment):
;;   - keyword-face:       magenta → green   (spec: keywords = green)
;;   - builtin-face:       green → magenta   (spec: language features = magenta)
;;   - constant-face:      purple → yellow   (spec: constants = yellow)
;;   - preprocessor-face:  default fg → magenta
;;   - comment-face:       tx-2 (wrong) → tx-3 (spec: comments = faint text)
;;   - doc-markup-face:    (new) tx-2 for @param/@return tags in doc comments
;;
;; New Emacs 29+ tree-sitter faces (not in upstream):
;;   - font-lock-number-face:      purple   (spec: numbers = purple)
;;   - font-lock-operator-face:    tx-2     (spec: punctuation/operators = muted)
;;   - font-lock-punctuation-face: tx-2
;;   - font-lock-bracket-face:     tx-2
;;   - font-lock-delimiter-face:   tx-2
;;   - font-lock-escape-face:      cyan
;;   - font-lock-property-use-face:  tx     (Helix: property = default text)
;;   - font-lock-property-name-face: tx
;;   - font-lock-function-call-face: orange (same as function-name)
;;   - font-lock-variable-use-face:  tx     (Helix: variable = default text)
;;
;; UI additions:
;;   - header-line face (background = ui) for modeline-at-top layout
;;
;; Removed upstream faces:
;;   - js2-mode, uiua-mode, neotree, company, web-mode (unused)
;;   - Stripped custom deffaces (flexoki-themes-*) and defcustom toggles
;;     (bold-keywords, italic-comments, etc.) for simplicity

;;; Code:

(defun flexoki-create (variant theme-name)
    "Define colours for THEME-NAME using VARIANT (`dark' or `light')."
    (let*
        ;; ── Neutral scale ──────────────────────────────────────────────
        ((black  "#100F0F")
            (n-950  "#1C1B1A")
            (n-900  "#282726")
            (n-850  "#343331")
            (n-800  "#403E3C")
            (n-700  "#575653")
            (n-600  "#6F6E69")
            (n-500  "#878580")
            (n-300  "#B7B5AC")
            (n-200  "#CECDC3")
            (n-100  "#E6E4D9")
            (n-50   "#F2F0E5")
            (paper  "#FFFCF0")

            ;; ── Semantic neutrals (per official spec) ────────────────────
            (bg      (if (eq variant 'light) paper  black))
            (bg-2    (if (eq variant 'light) n-50   n-950))
            (ui      (if (eq variant 'light) n-100  n-900))
            (ui-2    (if (eq variant 'light) n-200  n-850))
            (ui-3    (if (eq variant 'light) n-300  n-800))
            (tx-3    (if (eq variant 'light) n-300  n-700))
            (tx-2    (if (eq variant 'light) n-600  n-500))
            (tx      (if (eq variant 'light) black  n-200))

            ;; ── Accent colours ───────────────────────────────────────────
            (red     (if (eq variant 'light) "#AF3029" "#D14D41"))
            (orange  (if (eq variant 'light) "#BC5215" "#DA702C"))
            (yellow  (if (eq variant 'light) "#AD8301" "#D0A215"))
            (green   (if (eq variant 'light) "#66800B" "#879A39"))
            (cyan    (if (eq variant 'light) "#24837B" "#3AA99F"))
            (blue    (if (eq variant 'light) "#205EA6" "#4385BE"))
            (purple  (if (eq variant 'light) "#5E409D" "#8B7EC8"))
            (magenta (if (eq variant 'light) "#A02F6F" "#CE5D97")))

        (custom-theme-set-faces
            theme-name

            ;; ── Chrome ─────────────────────────────────────────────────────
            `(default                ((t (:background ,bg :foreground ,tx))))
            `(cursor                 ((t (:background ,tx))))
            `(fringe                 ((t (:background ,bg))))
            `(hl-line                ((t (:background ,ui-2))))
            `(region                 ((t (:background ,ui-3))))
            `(secondary-selection    ((t (:background ,ui-2))))
            `(vertical-border        ((t (:foreground ,ui-3))))
            `(internal-border        ((t (:background ,bg :foreground ,bg))))
            `(minibuffer-prompt      ((t (:foreground ,purple :weight semi-bold))))
            `(link                   ((t (:foreground ,blue :underline t))))
            `(shadow                 ((t (:foreground ,tx-2))))
            `(highlight              ((t (:background ,ui-2))))

            ;; ── Parens ─────────────────────────────────────────────────────
            `(show-paren-match       ((t (:background ,ui-3 :foreground ,yellow :weight bold))))
            `(show-paren-mismatch    ((t (:background ,ui-3 :foreground ,red :weight bold :box t))))

            ;; ── Status ─────────────────────────────────────────────────────
            `(error                  ((t (:foreground ,red :bold t))))
            `(success                ((t (:foreground ,green :bold t))))
            `(warning                ((t (:foreground ,yellow :bold t))))
            `(escape-glyph           ((t (:foreground ,cyan))))
            `(homoglyph              ((t (:foreground ,blue))))
            `(match                  ((t (:foreground ,bg :background ,blue))))

            ;; ── font-lock (official spec + Helix tree-sitter alignment) ───
            ;;
            ;; Spec mapping:
            ;;   keywords=green, functions=orange, constants=yellow,
            ;;   strings=cyan, variables/attributes=blue, numbers=purple,
            ;;   language-features=magenta, comments=tx-3,
            ;;   punctuation/operators=tx-2
            `(font-lock-keyword-face       ((t (:foreground ,green))))
            `(font-lock-builtin-face       ((t (:foreground ,magenta))))
            `(font-lock-function-name-face ((t (:foreground ,orange))))
            `(font-lock-variable-name-face ((t (:foreground ,blue))))
            `(font-lock-constant-face      ((t (:foreground ,yellow))))
            `(font-lock-type-face          ((t (:foreground ,yellow))))
            `(font-lock-string-face        ((t (:foreground ,cyan))))
            `(font-lock-comment-face       ((t (:foreground ,tx-3 :slant italic))))
            `(font-lock-doc-face           ((t (:foreground ,tx-3 :slant italic))))
            `(font-lock-doc-markup-face   ((t (:foreground ,tx-2))))
            `(font-lock-warning-face       ((t (:foreground ,yellow :weight bold))))
            `(font-lock-preprocessor-face  ((t (:foreground ,magenta))))
            `(font-lock-negation-char-face ((t (:foreground ,red))))

            ;; Emacs 29+ tree-sitter faces
            `(font-lock-number-face        ((t (:foreground ,purple))))
            `(font-lock-operator-face      ((t (:foreground ,tx-2))))
            `(font-lock-punctuation-face   ((t (:foreground ,tx-2))))
            `(font-lock-bracket-face       ((t (:foreground ,tx-2))))
            `(font-lock-delimiter-face     ((t (:foreground ,tx-2))))
            `(font-lock-escape-face        ((t (:foreground ,cyan))))
            `(font-lock-property-name-face ((t (:foreground ,tx))))
            `(font-lock-property-use-face  ((t (:foreground ,tx))))
            `(font-lock-function-call-face ((t (:foreground ,orange))))
            `(font-lock-variable-use-face  ((t (:foreground ,tx))))
            `(font-lock-misc-punctuation-face ((t (:foreground ,tx-2))))

            ;; ── Line numbers ──────────────────────────────────────────────
            `(line-number              ((t (:foreground ,ui-3))))
            `(line-number-current-line ((t (:foreground ,tx-2))))

            ;; ── Mode line ──────────────────────────────────────────────────
            `(header-line        ((t (:foreground ,tx :background ,ui :box nil))))
            `(mode-line          ((t (:foreground ,tx :background ,ui :box nil))))
            `(mode-line-inactive ((t (:foreground ,tx-2 :background ,bg :box nil))))

            ;; ── Tab bar / tab line ─────────────────────────────────────────
            `(tab-bar              ((t (:foreground ,tx :background ,bg))))
            `(tab-bar-tab          ((t (:foreground ,yellow :background ,bg
                                           :box (:line-width 1 :style released-button)))))
            `(tab-bar-tab-inactive ((t (:foreground ,tx-2 :background ,ui))))
            `(tab-line             ((t (:foreground ,tx :background ,bg))))
            `(tab-line-tab         ((t (:foreground ,yellow :background ,bg
                                           :box (:line-width 1 :style released-button)))))
            `(tab-line-tab-inactive ((t (:foreground ,tx-2 :background ,ui))))
            `(tab-line-close-highlight ((t (:foreground ,red))))

            ;; ── Isearch ────────────────────────────────────────────────────
            `(isearch        ((t (:foreground ,bg :background ,purple :weight bold))))
            `(isearch-fail   ((t (:background ,red))))
            `(isearch-group-1 ((t (:background ,magenta))))
            `(isearch-group-2 ((t (:background ,yellow))))
            `(lazy-highlight ((t (:foreground ,purple :background ,ui-3))))

            ;; ── Completion ─────────────────────────────────────────────────
            `(completions-annotations ((t (:foreground ,tx-2))))

            ;; ── Corfu ──────────────────────────────────────────────────────
            `(corfu-annotations ((t (:foreground ,tx-2))))
            `(corfu-bar         ((t (:foreground ,tx-2))))
            `(corfu-border      ((t (:foreground ,ui))))
            `(corfu-current     ((t (:foreground ,yellow :background ,ui-3))))
            `(corfu-default     ((t (:inherit default :background ,ui))))
            `(corfu-deprecated  ((t (:foreground ,tx-3))))
            `(corfu-echo        ((t (:inherit default))))

            ;; ── Vertico ────────────────────────────────────────────────────
            `(vertico-current         ((t (:weight bold :background ,ui-3))))
            `(vertico-group-separator ((t (:foreground ,tx-2 :strike-through t))))
            `(vertico-multiline       ((t (:foreground ,tx-2))))
            `(vertico-group-title     ((t (:foreground ,tx-2))))

            ;; ── Diff ───────────────────────────────────────────────────────
            `(diff-header          ((t (:foreground ,tx))))
            `(diff-file-header     ((t (:foreground ,tx))))
            `(diff-hunk-header     ((t (:foreground ,tx))))
            `(diff-context         ((t (:background ,ui))))
            `(diff-added           ((t (:foreground ,green))))
            `(diff-removed         ((t (:foreground ,red))))
            `(diff-changed         ((t (:foreground ,blue))))
            `(diff-refine-added    ((t (:foreground ,green))))
            `(diff-refine-removed  ((t (:foreground ,tx-2 :strike-through t))))
            `(diff-refine-changed  ((t (:foreground ,blue))))
            `(diff-indicator-added   ((t (:inherit diff-added))))
            `(diff-indicator-removed ((t (:inherit diff-removed))))
            `(diff-indicator-changed ((t (:inherit diff-changed))))

            ;; ── Diff-hl ────────────────────────────────────────────────────
            `(diff-hl-change ((t (:foreground ,blue))))
            `(diff-hl-delete ((t (:foreground ,red))))
            `(diff-hl-insert ((t (:foreground ,green))))

            ;; ── Ediff ──────────────────────────────────────────────────────
            `(ediff-even-diff-A        ((t (:background ,ui))))
            `(ediff-even-diff-B        ((t (:background ,ui))))
            `(ediff-even-diff-C        ((t (:background ,ui))))
            `(ediff-even-diff-Ancestor ((t (:background ,ui))))
            `(ediff-odd-diff-A         ((t (:background ,ui-2))))
            `(ediff-odd-diff-B         ((t (:background ,ui-2))))
            `(ediff-odd-diff-C         ((t (:background ,ui-2))))
            `(ediff-odd-diff-Ancestor  ((t (:background ,ui-2))))

            ;; ── Magit ──────────────────────────────────────────────────────
            `(magit-branch-local     ((t (:foreground ,purple))))
            `(magit-branch-remote    ((t (:foreground ,cyan))))
            `(git-commit-summary     ((t (:foreground ,green))))
            `(git-commit-overlong-summary ((t (:foreground ,red :weight semi-bold))))
            `(magit-dimmed           ((t (:foreground ,tx-2))))
            `(magit-blame-dimmed     ((t (:foreground ,tx-2))))
            `(magit-header-line      ((t (:foreground ,tx :background ,ui-2))))
            `(magit-header-line-log-select ((t (:foreground ,tx :background ,ui-2))))
            `(magit-section-heading    ((t (:foreground ,tx-2 :height 1.2))))
            `(magit-section-highlight  ((t (:background ,ui :extend t))))

            ;; ── Outline / headings ─────────────────────────────────────────
            `(outline-minor-0 ((t (:background ,ui :height 1.1))))
            `(outline-1 ((t (:foreground ,blue    :weight semi-bold))))
            `(outline-2 ((t (:foreground ,purple  :weight semi-bold))))
            `(outline-3 ((t (:foreground ,orange  :weight semi-bold))))
            `(outline-4 ((t (:foreground ,magenta :weight semi-bold))))
            `(outline-5 ((t (:foreground ,cyan    :weight semi-bold))))
            `(outline-6 ((t (:inherit outline-1))))
            `(outline-7 ((t (:inherit outline-2))))
            `(outline-8 ((t (:inherit outline-3))))

            ;; ── Markdown ───────────────────────────────────────────────────
            `(markdown-header-delimiter-face ((t (:foreground ,tx-2 :weight semi-bold))))
            `(markdown-header-face-1 ((t (:inherit outline-1))))
            `(markdown-header-face-2 ((t (:inherit outline-2))))
            `(markdown-header-face-3 ((t (:inherit outline-3))))
            `(markdown-header-face-4 ((t (:inherit outline-4))))
            `(markdown-header-face-5 ((t (:inherit outline-5))))
            `(markdown-header-face-6 ((t (:inherit outline-6))))
            `(markdown-url-face          ((t (:foreground ,cyan))))
            `(markdown-code-face         ((t (:foreground ,purple :background ,ui :extend t))))
            `(markdown-inline-code-face  ((t (:foreground ,purple))))
            `(markdown-footnote-marker-face ((t (:foreground ,tx-2))))
            `(markdown-list-face         ((t (:foreground ,tx-2))))
            `(markdown-markup-face       ((t (:foreground ,tx-3))))
            `(markdown-italic-face       ((t (:foreground ,orange :slant italic))))
            `(markdown-html-tag-delimiter-face ((t (:inherit default))))

            ;; ── Org ────────────────────────────────────────────────────────
            `(org-block          ((t (:inherit default :background ,ui))))
            `(org-code           ((t (:foreground ,purple))))
            `(org-date           ((t (:foreground ,green :underline t))))
            `(org-drawer         ((t (:foreground ,yellow))))
            `(org-todo           ((t (:foreground ,red :weight semi-bold))))
            `(org-done           ((t (:foreground ,tx-3))))
            `(org-headline-done  ((t (:foreground ,tx-3))))
            `(org-checkbox        ((t (:foreground ,green :weight semi-bold))))
            `(org-table           ((t (:foreground ,purple))))
            `(org-document-info   ((t (:foreground ,cyan))))
            `(org-document-title  ((t (:inherit org-document-info :weight bold))))

            ;; ── Dired ──────────────────────────────────────────────────────
            `(dired-symlink ((t (:foreground ,purple :weight bold))))

            ;; ── Eshell ─────────────────────────────────────────────────────
            `(eshell-prompt        ((t (:foreground ,yellow))))
            `(eshell-ls-archive    ((t (:foreground ,tx-2))))
            `(eshell-ls-backup     ((t (:foreground ,tx-2))))
            `(eshell-ls-clutter    ((t (:foreground ,orange :weight bold))))
            `(eshell-ls-directory  ((t (:foreground ,blue :weight bold))))
            `(eshell-ls-executable ((t (:weight bold))))
            `(eshell-ls-missing    ((t (:foreground ,red :bold t))))
            `(eshell-ls-special    ((t (:foreground ,yellow :bold t))))
            `(eshell-ls-symlink    ((t (:foreground ,purple))))
            `(eshell-ls-unreadable ((t (:foreground ,red :bold t))))

            ;; ── Term / vterm ───────────────────────────────────────────────
            `(term               ((t (:foreground ,tx :background ,bg))))
            `(term-bold          ((t (:weight bold))))
            `(term-color-black   ((t (:foreground ,black  :background ,black))))
            `(term-color-red     ((t (:foreground ,red    :background ,red))))
            `(term-color-green   ((t (:foreground ,green  :background ,green))))
            `(term-color-yellow  ((t (:foreground ,yellow :background ,yellow))))
            `(term-color-blue    ((t (:foreground ,blue   :background ,blue))))
            `(term-color-magenta ((t (:foreground ,magenta :background ,magenta))))
            `(term-color-cyan    ((t (:foreground ,cyan   :background ,cyan))))
            `(term-color-white   ((t (:foreground ,paper  :background ,paper))))

            ;; ── Buttons ────────────────────────────────────────────────────
            `(custom-button
                 ((t (:foreground ,purple :background ,ui
                         :box (:line-width (2 . 1) :style released-button)))))
            `(custom-button-mouse
                 ((t (:foreground ,purple :background ,bg
                         :box (:line-width (1 . 1) :color ,ui-3)))))
            `(custom-button-pressed
                 ((t (:foreground ,purple :background ,ui-3
                         :box (:line-width (2 . 1) :style pressed-button)))))

            ;; ── Comint ─────────────────────────────────────────────────────
            `(comint-highlight-prompt ((t (:foreground ,yellow :weight semi-bold))))

            ;; ── Rainbow delimiters ─────────────────────────────────────────
            `(rainbow-delimiters-depth-1-face  ((t (:foreground ,blue))))
            `(rainbow-delimiters-depth-2-face  ((t (:foreground ,orange))))
            `(rainbow-delimiters-depth-3-face  ((t (:foreground ,purple))))
            `(rainbow-delimiters-depth-4-face  ((t (:foreground ,yellow))))
            `(rainbow-delimiters-depth-5-face  ((t (:foreground ,cyan))))
            `(rainbow-delimiters-depth-6-face  ((t (:foreground ,magenta))))
            `(rainbow-delimiters-depth-7-face  ((t (:inherit rainbow-delimiters-depth-1-face))))
            `(rainbow-delimiters-depth-8-face  ((t (:inherit rainbow-delimiters-depth-2-face))))
            `(rainbow-delimiters-depth-9-face  ((t (:inherit rainbow-delimiters-depth-3-face))))
            `(rainbow-delimiters-depth-10-face ((t (:inherit rainbow-delimiters-depth-4-face))))
            `(rainbow-delimiters-depth-11-face ((t (:inherit rainbow-delimiters-depth-5-face))))
            `(rainbow-delimiters-depth-12-face ((t (:inherit rainbow-delimiters-depth-6-face))))
            `(rainbow-delimiters-unmatched-face ((t (:foreground ,red :weight bold))))

            ;; ── Which-key posframe ─────────────────────────────────────────
            `(which-key-posframe        ((t (:background ,ui))))
            `(which-key-posframe-border ((t (:background ,ui))))

            ;; ── Solaire ────────────────────────────────────────────────────
            `(solaire-default-face ((t (:background ,ui)))))))

;;;###autoload
(and load-file-name
    (boundp 'custom-theme-load-path)
    (add-to-list 'custom-theme-load-path
        (file-name-as-directory
            (file-name-directory load-file-name))))

(provide 'flexoki)

;;; flexoki.el ends here
