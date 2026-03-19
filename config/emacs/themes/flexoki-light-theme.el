;;; flexoki-light-theme.el --- Flexoki light theme -*- lexical-binding: t; -*-

;;; Code:
(require 'flexoki)

(deftheme flexoki-light
  "Flexoki light — spec-corrected."
  :family 'flexoki
  :kind 'color-scheme
  :background-mode 'light)

(flexoki-create 'light 'flexoki-light)

(provide-theme 'flexoki-light)

;;; flexoki-light-theme.el ends here
