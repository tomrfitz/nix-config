;;; early-init.el --- Pre-GUI Emacs configuration -*- lexical-binding: t; -*-

;; Defer GC during startup — restore to 16 MB after init
(setq gc-cons-threshold most-positive-fixnum)

;; Every `load'/`require' scans `file-name-handler-alist' (TRAMP, jka-compr,
;; etc.). Nothing loaded during init needs those handlers, so blank the alist
;; for the duration and restore it afterward — shaves the regex matching off
;; every file op on the startup path.
(defvar tf--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
    (lambda ()
        (setq gc-cons-threshold (* 16 1024 1024)
              file-name-handler-alist
              (delete-dups (append file-name-handler-alist
                                   tf--file-name-handler-alist)))))

;; Packages come from Nix via emacsWithPackagesFromUsePackage. :ensure t
;; in use-package blocks is consumed at *build time* by Nix's parser; at
;; runtime use-package's ensure-function is set to `ignore' in init.el so
;; no install attempts run.
;;
;; `package-enable-at-startup nil' suppresses Emacs's default
;; package-initialize (which would consult package-archives). We still need
;; to *activate* the nix-provided packages so their `<pkg>-autoloads.el'
;; files load — without that, `:init (foo-mode)' triggers void-function
;; because the autoload stubs were never registered. `package-activate-all'
;; walks installed packages on load-path and loads their autoloads without
;; enabling repos.
(setq package-enable-at-startup nil)
(package-activate-all)

;; Strip chrome before the first frame draws
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
(push '(horizontal-scroll-bars . nil) default-frame-alist)
(push '(fullscreen . maximized) default-frame-alist)

;; Pixel-level frame and window resizing
(setq frame-resize-pixelwise t
    window-resize-pixelwise t
    frame-inhibit-implied-resize t)

;; Suppress native-comp warnings; don't start background compiles on battery
;; (Emacs 31).
(setq native-comp-async-report-warnings-errors 'silent
    native-comp-async-on-battery-power nil)

;;; early-init.el ends here
