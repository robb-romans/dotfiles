                                        ; -*-Lisp-*-

;;
;; org-mode
;; https://www.reddit.com/r/emacs/comments/kynf5z/im_loving_orgmode/
;;
(use-package org
  :init
  (require 'org-habit)
  (require 'org-capture)
  (add-to-list 'auto-mode-alist '("\\.\\(org\\  |org_archive\\|txt\\)$" . org-mode))
  ;; (add-hook 'org-mode-hook 'turn-on-font-lock) ; not needed when global-font-lock-mode is on
  :bind (("\C-cl" . org-store-link)
         ("\C-ca" . org-agenda)
         ("\C-cb" . org-iswitchb))
  :config
  (setq org-directory '("~/org"))
  (setq org-agenda-files '("~/org"))
  :custom
  (org-todo-keyword-faces '(("NEXT" . "green") ("WAITING" . "yellow")))
  (org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAITING(w)" "|" "DONE(d)")))
  (org-agenda-start-with-log-mode t)
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-startup-folded 'content)
  ;; https://blog.aaronbieber.com/2017/03/19/organizing-notes-with-refile.html
  (org-outline-path-complete-in-steps nil)
  (org-refile-allow-creating-parent-nodes 'confirm)
  (org-refile-targets '((org-agenda-files :maxlevel . 2)))
  (org-refile-use-outline-path 'file))


;; Set to the name of the file where new notes will be stored
  ;; (org-mobile-inbox-for-pull "~/Projects/porg/flagged.org")
  ;; Set to <your Dropbox root directory>/MobileOrg.
  ;;(org-mobile-directory "~/MobileOrg")
  ;; Set to default capture file
  ;;(org-default-notes-file (concat org-directory "/notes.org"))


;; https://writequit.org/denver-emacs/presentations/2016-04-19-whats-new-emacs25-ditaa-artist.html
;; (org-babel-do-load-languages
;;      'org-babel-load-languages
;;      '((ditaa . t)))

;; https://www.shanesveller.com/blog/2018/02/13/blogging-with-org-mode-and-ox-hugo/
; (use-package ox-hugo
;   :after ox)

;; In-file encryption
;; (require 'org-crypt)
;; (org-crypt-use-before-save-magic)
;; (setq org-tags-exclude-from-inheritance (quote ("crypt")))
;; ;; GPG key to use for encryption
;; ;; Either the Key ID or set to nil to use symmetric encryption.
;; (setq org-crypt-key nil)

;;
;; Roam
;; https://github.com/org-roam
;;
(use-package org-roam
  :after org
  :custom
  (org-roam-directory (file-truename "~/org-roam"))
  (org-roam-db-location (file-truename "~/org-roam.db"))
  (org-roam-graph-viewer "/usr/bin/open")
  (org-roam-completion-everywhere t)
  ;; https://systemcrafters.cc/build-a-second-brain-in-emacs/getting-started-with-org-roam/
  ;; https://lucidmanager.org/productivity/taking-notes-with-emacs-org-mode-and-org-roam/
  :bind (("C-c n c" . org-roam-capture)
         ("C-c n f" . org-roam-node-find)
         ("C-c n j" . org-roam-dailies-capture-today)
         ("C-c n r" . org-roam-node-random)
         :map org-mode-map
         ("C-M-i"   . completion-at-point)
         ("C-c n a" . org-roam-alias-add)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n l" . org-roam-buffer-toggle)
         ("C-c n o" . org-id-get-create)
         ("C-c n t" . org-roam-tag-add))
  :config
  (org-roam-db-autosync-mode)
  ;; If using org-roam-protocol
  (require 'org-roam-protocol)
  :custom
  (safe-local-variable-values
   '((eval setq-local org-roam-db-location
           (expand-file-name "org-roam.db" org-roam-directory))
     (eval setq-local org-roam-directory
           (expand-file-name
            (locate-dominating-file default-directory ".dir-locals.el")))
     (nil . org-roam-directory)
     (nil . org-roam-db-location))))

;(use-package graphviz-dot-mode) ; requires company

(use-package org-download
  :after org
  :defer t
  :custom
  (with-eval-after-load 'org (org-download-enable)))
  ;;(org-download-image-dir "~/org/images"))
