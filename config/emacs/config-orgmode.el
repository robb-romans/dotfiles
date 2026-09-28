;;; config-orgmode.el --- Org, org-roam, org-download -*- lexical-binding: t; -*-

;; https://www.reddit.com/r/emacs/comments/kynf5z/im_loving_orgmode/
(use-package org
  :ensure nil
  :mode ("\\.txt\\'" . org-mode)
  :bind (("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c b" . org-switchb))
  :custom
  (org-directory "~/org")
  (org-agenda-files '("~/org"))
  (org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAITING(w)" "|" "DONE(d)")))
  (org-todo-keyword-faces '(("NEXT" . "green") ("WAITING" . "yellow")))
  (org-agenda-start-with-log-mode t)
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-startup-folded 'content)
  ;; https://blog.aaronbieber.com/2017/03/19/organizing-notes-with-refile.html
  (org-outline-path-complete-in-steps nil)
  (org-refile-allow-creating-parent-nodes 'confirm)
  (org-refile-targets '((org-agenda-files :maxlevel . 2)))
  (org-refile-use-outline-path 'file)
  :config
  (require 'org-habit))

;;; Roam https://github.com/org-roam/org-roam
;; https://systemcrafters.cc/build-a-second-brain-in-emacs/getting-started-with-org-roam/
;; https://lucidmanager.org/productivity/taking-notes-with-emacs-org-mode-and-org-roam/
(use-package org-roam
  :custom
  (org-roam-directory (file-truename "~/org-roam"))
  (org-roam-db-location (file-truename "~/org-roam.db"))
  (org-roam-graph-viewer "/usr/bin/open")
  (org-roam-completion-everywhere t)
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
  :init
  ;; Global keys autoload roam; opening any Org buffer loads it too, which
  ;; activates the org-mode-map keys below and database autosync.
  (with-eval-after-load 'org (require 'org-roam))
  ;; Let a .dir-locals.el point roam at a different directory and database
  (dolist (form '((eval setq-local org-roam-directory
                        (expand-file-name
                         (locate-dominating-file default-directory ".dir-locals.el")))
                  (eval setq-local org-roam-db-location
                        (expand-file-name "org-roam.db" org-roam-directory))))
    (add-to-list 'safe-local-variable-values form))
  :config
  (org-roam-db-autosync-mode 1)
  (require 'org-roam-protocol))

;; Drag and drop images into Org buffers; enables itself on load
(use-package org-download
  :after org)

;;; config-orgmode.el ends here
