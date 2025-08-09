;; Vertico
;; https://github.com/minad/vertico

(use-package vertico
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode))

(use-package savehist
  :init
  (savehist-mode))

;; Orderless across the board, save LSP/semantic categories
(use-package orderless
  :init
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides
        '((file (styles . (partial-completion)))))) ; file paths work better

;; handy consult defaults
(use-package consult
  :bind (("C-s" . consult-line)
         ("C-x b" . consult-buffer)
         ("M-g i" . consult-imenu))
  :init
  (setq consult-narrow-key "<"))  ; press < to narrow

;; marginalia annotations
(use-package marginalia
  :init (marginalia-mode))

;; embark is optional but powerful
(use-package embark :bind (("C-." . embark-act)))
