(require 'easycrypt-ext)
(require 'avy)

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

(provide 'easycrypt-ext-avy)

;;; easycrypt-ext-avy.el ends here
