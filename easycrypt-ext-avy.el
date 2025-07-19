(require 'easycrypt-ext)
(require 'avy)

;;; Customization
(defgroup easycrypt-ext-avy nil
  "Customization group for EasyCrypt Ext integration with Avy."
  :prefix "ece-avy"
  :group 'easycrypt-ext)

(defcustom ece-avy-dispatch-alist
  '((?= . avy-action-ece-proofshell-print-stay)
    (?+ . avy-action-ece-proofshell-print-move)
    (?/ . avy-action-ece-proofshell-search-stay)
    (?\\ . avy-action-ece-proofshell-search-move)
    (?- . avy-action-ece-proofshell-locate-stay)
    (?_ . avy-action-ece-proofshell-locate-move))
  "Alist containing (CHAR . FUNCTION) conses, each associating
dispatch action FUNCTION with key CHAR when executing
Avy commands. Used to (buffer-locally) extend `avy-dispatch-alist',
which see."
  :type '(alist :key-type character :value-type function)
  :group 'easycrypt-ext-avy)


;;; Dispatch actions
(defun ece--avy-action-ece-proofshell-command-move (command pt &rest args)
  "Moves point to PT (selected with Avy) and executes COMMAND with ARGS."
  (goto-char pt)
  (apply command args)
  t)

(defun ece--avy-action-ece-proofshell-command-stay (command pt &rest args)
  "Exectutes COMMAND with ARGS at PT (selected with Avy), leaving point."
  (unwind-protect
      (save-excursion
        (goto-char pt)
        (apply command args))
    (select-window
     (cdr (ring-ref avy-ring 0))))
  t)

;;;###autoload
(defun avy-action-ece-proofshell-print-move (pt)
  "Executes `ece-proofshell-print' at PT (selected with Avy), additionally
moving point to PT."
  (ece--avy-action-ece-proofshell-command-move #'ece-proofshell-print pt nil t))

;;;###autoload
(defun avy-action-ece-proofshell-print-stay (pt)
  "Executes `ece-proofshell-print' at PT (selected with Avy), leaving PT."
  (ece--avy-action-ece-proofshell-command-stay #'ece-proofshell-print pt nil t))

;;;###autoload
(defun avy-action-ece-proofshell-search-move (pt)
  "Executes `ece-proofshell-search' at PT (selected with Avy), additionally
moving point to PT."
  (ece--avy-action-ece-proofshell-command-move #'ece-proofshell-search pt nil t))

;;;###autoload
(defun avy-action-ece-proofshell-search-stay (pt)
  "Executes `ece-proofshell-search' at PT (selected with Avy), leaving PT."
  (ece--avy-action-ece-proofshell-command-stay #'ece-proofshell-search pt nil t))

;;;###autoload
(defun avy-action-ece-proofshell-locate-move (pt)
  "Executes `ece-proofshell-search' at PT (selected with Avy), additionally
moving point to PT."
  (ece--avy-action-ece-proofshell-command-move #'ece-proofshell-locate pt nil t))

;;;###autoload
(defun avy-action-ece-proofshell-locate-stay (pt)
  "Executes `ece-proofshell-search' at PT (selected with Avy), leaving PT."
  (ece--avy-action-ece-proofshell-command-stay #'ece-proofshell-locate pt nil t))


;;; Setup
(defun ece--easycrypt-ext-avy-setup (mode)
  "Adds (resp. removes) `ece-avy-dispatch-alist' dispatch actions to
`avy-dispatch-alist', buffer-locally, when MODE is non-nil (resp. `nil')."
  (if (symbol-value mode)
      (setq-local avy-dispatch-alist (append avy-dispatch-alist avy-ece-dal))
    (when (local-variable-p 'avy-dispatch-alist)
      (setq-local avy-dispatch-alist (delq nil
                                           (mapcar #'(lambda (dpa)
                                                       (unless (member dpa avy-ece-dal) dpa))
                                                   avy-dispatch-alist)))
      (when (equal avy-dispatch-alist (default-value 'avy-dispatch-alist))
        (kill-local-variable 'avy-dispatch-alist)))))

;;;###autoload
(defun easycrypt-ext-mode-avy-setup ()
  "Sets up Avy integration for `easycrypt-ext-mode'.

Meant for `easycrypt-ext-mode-hook'."
  (ece--easycrypt-ext-avy-setup 'easycrypt-ext-mode))

;;;###autoload
(defun easycrypt-ext-goals-mode-avy-setup ()
  "Sets up Avy integration for `easycrypt-ext-goals-mode'.

Meant for `easycrypt-ext-goals-mode-hook'."
  (ece--easycrypt-ext-avy-setup 'easycrypt-ext-goals-mode))

;;;###autoload
(defun easycrypt-ext-response-mode-avy-setup ()
  "Sets up Avy integration for `easycrypt-ext-response-mode'.

Meant for `easycrypt-ext-response-mode-hook'."
  (ece--easycrypt-ext-avy-setup 'easycrypt-ext-response-mode))

(provide 'easycrypt-ext-avy)

;;; easycrypt-ext-avy.el ends here
