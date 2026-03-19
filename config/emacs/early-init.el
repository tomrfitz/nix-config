;;; early-init.el --- Pre-GUI Emacs configuration -*- lexical-binding: t; -*-

;; Defer GC during startup — restore to 16 MB after init
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 16 1024 1024))))

;; Strip chrome before the first frame draws
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
(push '(horizontal-scroll-bars . nil) default-frame-alist)
(push '(fullscreen . maximized) default-frame-alist)

;; Pixel-level frame resizing
(setq frame-resize-pixelwise t
      frame-inhibit-implied-resize t)

;; Suppress native-comp warnings
(setq native-comp-async-report-warnings-errors 'silent)

;;; early-init.el ends here
