;;; early-init.el --- Pre-GUI Emacs configuration -*- lexical-binding: t; -*-

;; Defer GC during startup — gcmh restores a sane threshold after init
(setq gc-cons-threshold most-positive-fixnum)

;; Suppress file-name-handler-alist regex matching during init
(defvar tf/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
    (lambda ()
        (setq file-name-handler-alist
            (delete-dups (append file-name-handler-alist tf/file-name-handler-alist)))))

;; Prevent white flash on dark themes
(setq-default inhibit-redisplay t
              inhibit-message t)
(add-hook 'window-setup-hook
    (lambda ()
        (setq-default inhibit-redisplay nil
                      inhibit-message nil)
        (redisplay)))

;; Disable bidi scanning (no RTL text)
(setq-default bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)

;; Rendering/scrolling performance
(setq redisplay-skip-fontification-on-input t
      fast-but-imprecise-scrolling t
      inhibit-compacting-font-caches t
      cursor-in-non-selected-windows nil
      highlight-nonselected-windows nil)

;; Prefer source over stale bytecode
(setq load-prefer-newer t)

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
