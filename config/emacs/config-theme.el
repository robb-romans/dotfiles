                                        ; -*-Lisp-*-

;; Theme
(use-package material-theme
  :config (load-theme 'material t)
  (let ((line (face-attribute 'mode-line :underline)))
    (set-face-attribute 'mode-line          nil :overline   line)
    (set-face-attribute 'mode-line-inactive nil :overline   line)
    (set-face-attribute 'mode-line-inactive nil :underline  line)
    (set-face-attribute 'mode-line          nil :box        nil)
    (set-face-attribute 'mode-line-inactive nil :box        nil)))

(use-package zenburn-theme
  :config
  (setq zenburn-override-colors-alist
        '(
          ;; Zenburn HC
          ;; https://github.com/edran/hc-zenburn-emacs/blob/master/hc-zenburn-theme.el
          ("zenburn-fg+1"     . "#FFFFEF")
          ("zenburn-fg"       . "#DCDCCC")
          ("zenburn-fg-1"     . "#70705E")
          ("zenburn-bg-2"     . "#000000")
          ("zenburn-bg-1"     . "#202020")
          ("zenburn-bg-05"    . "#2D2D2D")
          ("zenburn-bg"       . "#313131")
          ("zenburn-bg+05"    . "#383838")
          ("zenburn-bg+1"     . "#3E3E3E")
          ("zenburn-bg+2"     . "#4E4E4E")
          ("zenburn-bg+3"     . "#5E5E5E")
          ("zenburn-red+1"    . "#E9B0B0")
          ("zenburn-red"      . "#D9A0A0")
          ("zenburn-red-1"    . "#C99090")
          ("zenburn-red-2"    . "#B98080")
          ("zenburn-red-3"    . "#A97070")
          ("zenburn-red-4"    . "#996060")
          ("zenburn-orange"   . "#ECBC9C")
          ("zenburn-yellow"   . "#FDECBC")
          ("zenburn-yellow-1" . "#EDDCAC")
          ("zenburn-yellow-2" . "#DDCC9C")
          ("zenburn-green-1"  . "#6C8C6C")
          ("zenburn-green"    . "#8CAC8C")
          ("zenburn-green+1"  . "#9CBF9C")
          ("zenburn-green+2"  . "#ACD2AC")
          ("zenburn-green+3"  . "#BCE5BC")
          ("zenburn-green+4"  . "#CCF8CC")
          ("zenburn-cyan"     . "#A0EDF0")
          ("zenburn-blue+1"   . "#9CC7FB")
          ("zenburn-blue"     . "#99DDE0")
          ("zenburn-blue-1"   . "#89C5C8")
          ("zenburn-blue-2"   . "#79ADB0")
          ("zenburn-blue-3"   . "#699598")
          ("zenburn-blue-4"   . "#597D80")
          ("zenburn-blue-5"   . "#436D6D")
          ("zenburn-magenta"  . "#E090C7")))
  )
;;   (load-theme 'zenburn t))


;; https://blog.jft.rocks/emacs/time-based-theme.html
;; (defun set-light-theme ()
;;   "Set the light theme with some customization if needed."
;;   (interactive)
;;   (load-theme 'doom-solarized-light t))

;; (defun set-dark-theme ()
;;   "Set the dark theme with some customization if needed."
;;   (interactive)
;;   (load-theme 'doom-tomorrow-night t))

;; (let ((current-hour (string-to-number (format-time-string "%H"))))
;;   (if (or (< current-hour 6) (> current-hour 20)) (set-light-theme) (set-dark-theme)))

;; (defun theme-switcher ()
;;   (let ((current-hour (string-to-number (format-time-string "%H"))))
;;     (if (or (< current-hour 6) (> current-hour 20)) (set-light-theme) (set-dark-theme))))

;; Run at every 3600 seconds, after 0s delay
;(run-with-timer 0 3600 'theme-switcher)
