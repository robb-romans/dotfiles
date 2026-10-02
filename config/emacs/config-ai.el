;;; config-ai.el --- AI coding assistants -*- lexical-binding: t; -*-

;;; Terminal https://github.com/akermu/emacs-libvterm
;; Compiles a native module on first install (needs cmake and libtool from Homebrew).
(use-package vterm
  :defer t
  :custom
  (vterm-max-scrollback 10000) ; the default 1000 lines truncates resumed conversations
  :config
  ;; Claude's spinner cycles through dingbats (✢ ✳ ✶ ✻ ✽). Emacs may fall back to a
  ;; taller emoji or symbol font for some of them, which changes the line height on
  ;; each frame and makes the text bounce. Render them in the default font instead.
  (defun rr/vterm-pin-spinner-font ()
    "Prefer the default font family for dingbats (fontsets are global)."
    (let ((family (face-attribute 'default :family nil 'default)))
      (set-fontset-font t '(#x2720 . #x273f) (font-spec :family family) nil 'prepend)))
  (add-hook 'vterm-mode-hook #'rr/vterm-pin-spinner-font)

  ;; The TUI redraws its bottom lines constantly. Keep Emacs from nudging the window
  ;; vertically (auto-window-vscroll, recentering) while it does.
  (defun rr/vterm-steady-scrolling ()
    "Stop redraws from shifting the window by sub-line amounts in this vterm buffer."
    (setq-local auto-window-vscroll nil
                scroll-conservatively 101
                scroll-margin 0))
  (add-hook 'vterm-mode-hook #'rr/vterm-steady-scrolling))

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
