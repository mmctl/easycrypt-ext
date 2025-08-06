(require 'easycrypt-ext)
(require 'easycrypt-ext-const)

(require 'cape-keyword)

;; Keyword completion
(defun ece--enable-keyword-completion ()
  "Enables keyword completion for EasyCrypt (via `cape-keyword')."
  (add-to-list 'cape-keyword-list (cons 'easycrypt-mode ece-keywords)))

(defun ece--disable-keyword-completion ()
  "Disables keyword completion for EasyCrypt (via `cape-keyword')."
  (setq cape-keyword-list (assq-delete-all 'easycrypt-mode cape-keyword-list)))

(defun easycrypt-ext-mode-cape-setup ()
  "Sets up (and tears down) `cape' integration for `easycrypt-ext-mode',
specifically `cape-keyword' for keyword completion.

Meant for `easycrypt-ext-mode-hook'."
  (if easycrypt-ext-mode
      (ece--enable-keyword-completion)
    (ece--disable-keyword-completion)))

