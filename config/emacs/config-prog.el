;;; config-prog.el --- Programming and markup modes -*- lexical-binding: t; -*-

;;; Whitespace
(setq-default indent-tabs-mode nil)
(add-hook 'prog-mode-hook (lambda () (setq show-trailing-whitespace t)))
(add-hook 'before-save-hook #'delete-trailing-whitespace)
(global-set-key (kbd "C-c w") #'whitespace-mode)

(setq c-default-style "python")

;;; Tree-sitter
;; Prefer *-ts-mode wherever one exists, and offer to download and
;; compile a missing grammar the first time it's needed.
;; setopt, not setq: treesit-enabled-modes applies itself via its :set function.
(setopt treesit-enabled-modes t
        treesit-auto-install-grammar 'ask)

;;; LSP via Eglot
(defvar rr/eglot-servers
  '((python-base-mode "basedpyright-langserver" "pyright-langserver" "pylsp")
    (go-ts-mode       "gopls")
    (yaml-ts-mode     "yaml-language-server")
    (bash-ts-mode     "bash-language-server")
    (json-ts-mode     "vscode-json-language-server")
    (markdown-mode    "marksman"))
  "Major modes that start Eglot, each with the servers that qualify.
Eglot only starts when one of the listed executables is installed.")

(defun rr/eglot-ensure-if-installed ()
  "Run `eglot-ensure' if this mode has an installed server in `rr/eglot-servers'."
  (when-let* ((entry (seq-find (lambda (e) (derived-mode-p (car e))) rr/eglot-servers)))
    (when (seq-some #'executable-find (cdr entry))
      (eglot-ensure))))

(use-package eglot
  :ensure nil
  :defer t
  :init
  (dolist (entry rr/eglot-servers)
    (add-hook (intern (format "%s-hook" (car entry))) #'rr/eglot-ensure-if-installed))
  :custom
  (eglot-autoshutdown t))

;;; Markdown https://jblevins.org/projects/markdown-mode/
(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.text\\'"     . markdown-mode))
  :hook (markdown-mode . (lambda ()
                           (when buffer-file-name
                             (add-hook 'after-save-hook #'check-parens nil t)))))

;;; reStructuredText http://docutils.sourceforge.net/docs/user/emacs.html
(use-package rst
  :ensure nil
  :defer t
  :custom
  (rst-indent-field 4)
  (rst-indent-literal-normal 4)
  (rst-indent-comment 4)
  (rst-preferred-adornments '((?= over-and-under 0)
                              (?~ simple 0)
                              (?- simple 0)
                              (?+ simple 0)
                              (?` simple 0)
                              (?# simple 0)
                              (?@ simple 0))))

;;; XML https://fedoraproject.org/wiki/How_to_use_Emacs_for_XML_editing
(use-package nxml-mode
  :ensure nil
  :mode "\\.\\(xml\\|xsl\\|xhtml\\|page\\)\\'"  ; .page is Mallard
  :config
  (with-eval-after-load 'rng-loc
    (add-to-list 'rng-schema-locating-files "~/.schema/schemas.xml")))

;;; config-prog.el ends here
