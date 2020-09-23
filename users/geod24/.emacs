;; -*- emacs-lisp -*-

;; Packages I use:
;; - d-mode (Thx Russel Winder !)
;; - column-enforce-mode
;; - editorconfig
;;
;; My work on dlang is stored under ~/projects/dlang/{dmd,druntime,phobos,...}
;; My other projects live happily in ~/projects/

;;;;;;;;;;;;;;;;;; melpa  setting ;;;;;;;;;;;;;;;;;;;;;;
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;;;;;;;;;;;;;;;;;; quelpa setting ;;;;;;;;;;;;;;;;;;;;;;
; activate all the packages (in particular autoloads)
;(package-initialize)

;(unless (package-installed-p 'quelpa)
;    (with-temp-buffer
;      (url-insert-file-contents "https://github.com/quelpa/quelpa/raw/master/quelpa.el")
;      (eval-buffer)
;      (quelpa-self-upgrade)))

;(setq quelpa-checkout-melpa-p nil)
;(setq quelpa-upgrade-interval 7)
;(add-hook #'after-init-hook #'quelpa-upgrade-all-maybe)

;(quelpa
; '(quelpa-use-package
;   :fetcher git
;   :url "https://github.com/quelpa/quelpa-use-package.git"))
;(require 'quelpa-use-package)

;(use-package d-mode
;  :ensure nil
;  :quelpa (d-mode
;           :fetcher github
;           :repo "CyberShadow/Emacs-D-Mode"
;           :branch "next"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Diet files
(add-to-list 'auto-mode-alist '("\\.dt?\\'" . d-mode))

;; DMD / druntime/ phobos code style
;; FIXME: Config for dlang vs Vibe.d vs .. ?
(load "editorconfig")
(add-to-list 'auto-mode-alist '("\\.mak\\'" . makefile-gmake-mode))
(add-to-list 'auto-mode-alist '("APKBUILD\\'" . shell-script-mode))

;; Handy alias
(defalias 'gt 'goto-line)
(defalias 'clean 'delete-trailing-whitespace)

;; My workplace style
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4) ; or any other preferred value
(defvaralias 'c-basic-offset 'tab-width)
(setq c-default-style "bsd" c-basic-offset 4)

;; Eighty-column rule
(defun eighty-rule-hook ()
   (column-enforce-mode 1))
(add-hook 'd-mode-hook 'eighty-rule-hook)

;; On save hooks (who wants trailing whitespace ?)
(add-hook 'before-save-hook 'delete-trailing-whitespace)
;; On save hooks (who wants trailing whitespace ?)
(defun cleanup-dlang ()
  (add-hook 'before-save-hook 'delete-trailing-whitespace))
(add-hook 'd-mode-hook 'cleanup-dlang)
(add-hook 'c-mode-hook 'cleanup-dlang)
(add-hook 'c++-mode-hook 'cleanup-dlang)
(add-hook 'fundamental-mode-hook 'cleanup-dlang)
(add-hook 'yaml-mode-hook 'cleanup-dlang)

; Make diff-mode usable
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(diff-added ((t (:inherit diff-changed :background "green" :foreground "red"))))
 '(diff-header ((t (:background "yellow" :foreground "black"))))
 '(diff-indicator-added ((t (:inherit diff-added :background "green" :foreground "red"))))
 '(diff-indicator-removed ((t (:inherit diff-removed :background "red" :foreground "green"))))
 '(diff-removed ((t (:inherit diff-changed :background "red" :foreground "green")))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (editorconfig d-mode column-enforce-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
