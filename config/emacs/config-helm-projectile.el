                                        ; -*-Lisp-*-

;; config-helm-projectile.el

;;
;; Helm
;; https://people.gnome.org/~federico/blog/bringing-my-emacs-from-the-past.html
(use-package helm
 :diminish
 :init (helm-mode t)
 :bind (("M-x"     . helm-M-x)
        ("C-x C-m" . helm-M-x)
        ("C-x C-f" . helm-find-files)
        ("C-x b"   . helm-mini)     ;; See buffers & recent files; more useful
        ("C-x r b" . helm-filtered-bookmarks)
        ("C-x C-r" . helm-recentf)  ;; Search for recently edited files
        ("C-c i"   . helm-imenu)
        ("C-h a"   . helm-apropos)
        ("M-y"     . helm-show-kill-ring)
        :map helm-map
        ;; List ‘actions’ on the currently selected item with C-z
        ("C-z"     . helm-select-action)
        ;; Keep tab completetion
        ("TAB"     . helm-execute-persistent-action)
        ("<tab>"   . helm-execute-persistent-action)))


(use-package helm-projectile
  :requires (helm)
  :config
  (projectile-cleanup-known-projects))


;; Projectile
(use-package projectile
  :diminish projectile-mode
  :custom
  (projectile-completion-system 'helm)
  (add-to-list 'projectile-globally-unignored-files (quote (".DS_Store")))
  ;; (add-to-list 'projectile-globally-ignored-directories "backup")
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/Projects")
    (setq projectile-project-search-path '("~/Projects")))
  (setq projectile-switch-project-action #'projectile-dired))


;; Ripgrep
;; (use-package rg
;;   :config
;;   (global-set-key (kbd "M-s g") 'rg)
;;   (global-set-key (kbd "M-s d") 'rg-dwim))
;; (use-package helm-rg)
