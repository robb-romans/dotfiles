;;; config-completion.el --- Minibuffer and in-buffer completion -*- lexical-binding: t; -*-

;;; Minibuffer: vertico + orderless + marginalia + consult + embark
;; https://github.com/minad/vertico
(use-package vertico
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode 1))

(use-package emacs
  :ensure nil
  :custom
  (enable-recursive-minibuffers t)
  ;; Hide M-x commands that don't apply to the current mode
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Don't offer ispell word completions in prose buffers
  (text-mode-ispell-word-completion nil)
  ;; TAB indents, or completes if the line is already indented
  (tab-always-indent 'complete))

;; Persist minibuffer history, which vertico uses for sorting
(use-package savehist
  :ensure nil
  :init
  (savehist-mode 1))

;; Space-separated components matched in any order; file paths use partial-completion
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :init
  (marginalia-mode 1))

(use-package consult
  :bind (("C-s"     . consult-line)
         ("C-x b"   . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x r b" . consult-bookmark)
         ("M-y"     . consult-yank-pop)
         ("M-g g"   . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g i"   . consult-imenu)
         ("M-s r"   . consult-ripgrep))
  :custom
  (consult-narrow-key "<"))             ; press < to narrow

(use-package embark
  :bind (("C-."   . embark-act)
         ("C-h B" . embark-bindings)))

(use-package embark-consult
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;;; In-buffer: corfu popups for completion-at-point
;; https://github.com/minad/corfu
(use-package corfu
  :custom
  (corfu-cycle t)
  :init
  (global-corfu-mode 1)
  ;; Pop up automatically in code; elsewhere, TAB or C-M-i opens it
  (add-hook 'prog-mode-hook
            (lambda () (setq-local corfu-auto t))))

;;; config-completion.el ends here
