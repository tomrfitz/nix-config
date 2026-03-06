;;; init.el -*- lexical-binding: t; -*-

(doom! :input
       ;;bidi
       ;;chinese
       ;;japanese
       ;;layout

       :completion
       (corfu +orderless)
       vertico

       :ui
       doom
       doom-dashboard
       hl-todo
       modeline
       ophints
       (popup +defaults)
       (vc-gutter +pretty)
       vi-tilde-fringe
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       snippets
       (whitespace +guess +trim)

       :emacs
       dired
       electric
       tramp
       undo
       vc

       :term
       vterm

       :checkers
       syntax

       :tools
       direnv
       editorconfig
       (eval +overlay)
       lookup
       magit
       tree-sitter

       :os
       (:if (featurep :system 'macos) macos)
       tty

       :lang
       emacs-lisp
       markdown
       nix
       org
       (python +lsp +tree-sitter)
       sh
       ;;yaml

       :config
       (default +bindings +smartparens))
