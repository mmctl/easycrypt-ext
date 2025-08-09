(require 'easycrypt-ext)
(require 'easycrypt-ext-consts)

(require 'cape-keyword)


;;; Keyword completion
(defun ece-cape--enable-keyword-completion ()
  "Enables keyword completion for EasyCrypt (via `cape-keyword')."
  (add-to-list 'cape-keyword-list (cons 'easycrypt-mode ece-keywords)))

(defun ece-cape--disable-keyword-completion ()
  "Disables keyword completion for EasyCrypt (via `cape-keyword')."
  (setq cape-keyword-list (assq-delete-all 'easycrypt-mode cape-keyword-list)))

;;;###autoload
(defun easycrypt-ext-mode-cape-setup ()
  "Sets up (and tears down) `cape' integration for `easycrypt-ext-mode',
specifically `cape-keyword' for keyword completion.

Meant for `easycrypt-ext-mode-hook'."
  (if easycrypt-ext-mode
      (ece-cape--enable-keyword-completion)
    (ece-cape--disable-keyword-completion)))


(provide 'easycrypt-ext-cape)

;;; easycrypt-ext-cape.el ends here
