;;; config-ai.el --- AI coding assistants -*- lexical-binding: t; -*-

;;; Terminal https://github.com/akermu/emacs-libvterm
;; Compiles a native module on first install (needs cmake and libtool from Homebrew).
(use-package vterm
  :defer t
  :custom
  (vterm-max-scrollback 10000)) ; the default 1000 lines truncates resumed conversations

;;; Claude Code https://github.com/manzaltu/claude-code-ide.el
;; Runs the claude CLI in a vterm side window and connects it to Emacs over MCP,
;; so Claude sees the current file and selection and shows its edits in ediff.
(use-package claude-code-ide
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)
  :bind ("C-c c" . claude-code-ide-menu)
  :custom
  (claude-code-ide-terminal-backend 'vterm)
  (claude-code-ide-show-backend-recommendation nil) ; don't suggest ghostel
  (claude-code-ide-window-side 'right)
  (claude-code-ide-window-width 100)
  :config
  ;; Let Claude call xref (Eglot), tree-sitter, imenu, and project.el in this Emacs.
  (claude-code-ide-emacs-tools-setup))

;;; config-ai.el ends here
