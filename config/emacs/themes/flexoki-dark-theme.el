;;; flexoki-dark-theme.el --- Flexoki dark theme -*- lexical-binding: t; -*-

;;; Code:
(require 'flexoki)

(deftheme flexoki-dark
    "Flexoki dark — spec-corrected."
    :family 'flexoki
    :kind 'color-scheme
    :background-mode 'dark)

(flexoki-create 'dark 'flexoki-dark)

(provide-theme 'flexoki-dark)

;;; flexoki-dark-theme.el ends here
