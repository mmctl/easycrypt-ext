;;; easycrypt-ext-tempel.el --- Avy Integration for EasyCrypt Ext -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2025 Matthias Meijers

;; Author: Matthias Meijers <kernel@mmeijers.com>
;; Maintainer: Matthias Meijers <kernel@mmeijers.com>
;; URL: https://github.com/mmctl/easycrypt-ext

;; This file is not part of GNU Emacs.

;; This file is free software: you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free Software
;; Foundation, either version 3 of the License, or (at your option) any later
;; version. This file is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
;; details. You should have received a copy of the GNU General Public License
;; along with this program. If not, see <https://www.gnu.org/licenses/>.

;; Package-Requires: ((emacs "29.1") (avy "0.5.0") (easycrypt-ext))

;;; Commentary:
;; Avy integration for EasyCrypt Ext, enabling actions from a distance.
;;
;; For setup and usage instructions, see the README at
;; https://github.com/mmctl/easycrypt-ext
;;
;; For more information on Avy, visit
;; https://github.com/abo-abo/avy

;;; Code:

(require 'easycrypt-ext)
(require 'avy)

;;; Customization
(defgroup easycrypt-ext-avy nil
  "Customization group for EasyCrypt Ext integration with `avy'."
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
`avy' commands. Used to (buffer-locally) extend `avy-dispatch-alist',
which see."
  :type '(alist :key-type character :value-type function)
  :group 'easycrypt-ext-avy)


;;; Dispatch actions
(defun ece-avy--action-ece-proofshell-command-move (command pt &rest args)
  "Moves point to PT (selected with `avy') and executes COMMAND with ARGS."
  (goto-char pt)
  (apply command args)
  t)

(defun ece-avy--action-ece-proofshell-command-stay (command pt &rest args)
  "Exectutes COMMAND with ARGS at PT (selected with `avy'), leaving point."
  (unwind-protect
      (save-excursion
        (goto-char pt)
        (apply command args))
    (select-window
     (cdr (ring-ref avy-ring 0))))
  t)

;;;###autoload
(defun avy-action-ece-proofshell-print-move (pt)
  "Executes `ece-proofshell-print' at PT (selected with `avy'), additionally
moving point to PT."
  (ece-avy--action-ece-proofshell-command-move #'ece-proofshell-print pt nil t))

;;;###autoload
(defun avy-action-ece-proofshell-print-stay (pt)
  "Executes `ece-proofshell-print' at PT (selected with `avy'), leaving PT."
  (ece-avy--action-ece-proofshell-command-stay #'ece-proofshell-print pt nil t))

;;;###autoload
(defun avy-action-ece-proofshell-search-move (pt)
  "Executes `ece-proofshell-search' at PT (selected with `avy'), additionally
moving point to PT."
  (ece-avy--action-ece-proofshell-command-move #'ece-proofshell-search pt nil t))

;;;###autoload
(defun avy-action-ece-proofshell-search-stay (pt)
  "Executes `ece-proofshell-search' at PT (selected with `avy'), leaving PT."
  (ece-avy--action-ece-proofshell-command-stay #'ece-proofshell-search pt nil t))

;;;###autoload
(defun avy-action-ece-proofshell-locate-move (pt)
  "Executes `ece-proofshell-search' at PT (selected with `avy'), additionally
moving point to PT."
  (ece-avy--action-ece-proofshell-command-move #'ece-proofshell-locate pt nil t))

;;;###autoload
(defun avy-action-ece-proofshell-locate-stay (pt)
  "Executes `ece-proofshell-search' at PT (selected with `avy'), leaving PT."
  (ece-avy--action-ece-proofshell-command-stay #'ece-proofshell-locate pt nil t))


;;; Setup and teardown
(defun ece-avy--easycrypt-ext-avy-setup (mode)
  "Adds (resp. removes) `ece-avy-dispatch-alist' dispatch actions to
`avy-dispatch-alist', buffer-locally, when MODE is non-nil (resp. `nil')."
  (if (symbol-value mode)
      (setq-local avy-dispatch-alist (append avy-dispatch-alist ece-avy-dispatch-alist))
    (when (local-variable-p 'avy-dispatch-alist)
      (setq-local avy-dispatch-alist (delq nil
                                           (mapcar #'(lambda (dpa)
                                                       (unless (member dpa ece-avy-dispatch-alist) dpa))
                                                   avy-dispatch-alist)))
      (when (equal avy-dispatch-alist (default-value 'avy-dispatch-alist))
        (kill-local-variable 'avy-dispatch-alist)))))

;;;###autoload
(defun easycrypt-ext-mode-avy-setup ()
  "Sets up `avy' integration for `easycrypt-ext-mode'.

Meant for `easycrypt-ext-mode-hook'."
  (ece-avy--easycrypt-ext-avy-setup 'easycrypt-ext-mode))

;;;###autoload
(defun easycrypt-ext-goals-mode-avy-setup ()
  "Sets up `avy' integration for `easycrypt-ext-goals-mode'.

Meant for `easycrypt-ext-goals-mode-hook'."
  (ece-avy--easycrypt-ext-avy-setup 'easycrypt-ext-goals-mode))

;;;###autoload
(defun easycrypt-ext-response-mode-avy-setup ()
  "Sets up `avy' integration for `easycrypt-ext-response-mode'.

Meant for `easycrypt-ext-response-mode-hook'."
  (ece-avy--easycrypt-ext-avy-setup 'easycrypt-ext-response-mode))


(provide 'easycrypt-ext-avy)

;;; easycrypt-ext-avy.el ends here
