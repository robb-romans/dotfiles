;;; config-theme.el --- Theme and mode line -*- lexical-binding: t; -*-

;; Moody draws its own tabs, so swap the theme's mode-line boxes for
;; over/underlines in the same color. Runs after every theme load.
(defun rr/moody-style-mode-line (&rest _)
  "Replace mode-line boxes with over/underlines, as Moody expects."
  (dolist (face '(mode-line-active mode-line-inactive))
    (let* ((box (face-attribute face :box nil t))
           (color (cond ((stringp box) box)
                        ((consp box) (plist-get box :color))
                        (t (face-foreground 'shadow nil t)))))
      (set-face-attribute face nil :box 'unspecified)
      (when color                       ; nil on terminals without color
        (set-face-attribute face nil
                            :overline color
                            :underline `(:color ,color :position t))))))
(add-hook 'enable-theme-functions #'rr/moody-style-mode-line)

;; Modus themes ship with Emacs. M-x modus-themes-toggle switches to light.
(mapc #'disable-theme custom-enabled-themes)
(load-theme 'modus-vivendi t)

;; https://github.com/tarsius/moody
(use-package moody
  :config
  (moody-replace-mode-line-front-space)
  (moody-replace-mode-line-buffer-identification)
  (moody-replace-vc-mode))

;; Collapse minor modes into a single menu
(use-package minions
  :config
  (minions-mode 1))

;;; config-theme.el ends here
