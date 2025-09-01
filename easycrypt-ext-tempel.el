;;; easycrypt-ext-tempel.el --- Tempel Integration for EasyCrypt Ext -*- lexical-binding: t; -*-
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

;; Package-Requires: ((emacs "29.1") (tempel "1.5"))

;;; Commentary:
;; Tempel integration for EasyCrypt Ext, providing code template functionality.
;; Templates are defined in `easycrypt-ext-templates.eld'.

;; For setup and usage instructions, see the README at
;; https://github.com/mmctl/easycrypt-ext

;; For more information on Tempel, visit
;; https://github.com/minad/tempel

;;; Code:


(require 'easycrypt-ext)
(require 'tempel)


;;; Customization
(defgroup easycrypt-ext-tempel nil
  "Customization group for EasyCrypt Ext integration with `tempel'."
  :prefix "ece-tempel"
  :group 'easycrypt-ext)

(defcustom ece-tempel-template-map-entries
    '(("a" axin) ("A" abbn) ("b" bye) ("B" byp)
    ("c" cons) ("C" conseqehh) ("d" docc) ("D" decmod)
    ("e" equn) ("E" equnln) ("f" funn) ("F" fel)
    ("g" ge0) ("G" gt0) ("h" hoan) ("H" hoanln)
    ("i" ifel) ("I" ifte) ("l" lemn) ("L" letinn)
    ("m" mod) ("M" modpt) ("o" op) ("O" opas)
    ("p" pro) ("P" pros) ("r" rewd) ("R" rngin)
    ("s" seq) ("S" seqp) ("t" modtyp) ("T" modtypp)
    ("u" Prm) ("U" Prmr) ("v" movi) ("V" smt)
    ("w" whi) ("W" while) ("x" cloimpaswi) ("X" reqimp)
    ("y" phon) ("Y" pho1n) ("z" the) ("Z" absthe))
  "Alist of (KEY TEMPLATE-NAME) pairs for which KEY should be bound to
TEMPLATE-NAME in `ece-template-map'. KEY should be a string satisfying
`key-valid-p', which see, and TEMPLATE-NAME should be a symbol matching a
template specified in the template file `eascyrypt-ext-templates.eld'."
  :type '(alist :key-type key :value-type symbol)
  :group 'easycrypt-ext-tempel)

(defcustom ece-tempel-template-map-prefix "C-c C-y t"
  "Prefix for accessing `ece-template-map'. Should be a valid key (sequence) as
per `key-valid-p', which see."
  :type 'key
  :group 'easycrypt-ext-tempel)


;;; Constants
(defconst ece--templates-file
  (expand-file-name "easycrypt-ext-templates.eld" ece--dir)
  "File where code templates for EasyCrypt are stored.")


;;; Tempel elements
(defun ece-tempel--include (elt)
  "Defines `include' element (taken and slightly adjusted from TempEL github repo)
that allows to include other templates by their name."
  (when (eq (car-safe elt) 'i)
    (when-let (template (alist-get (cadr elt) (tempel--templates)))
      (cons 'l template))))


;;; Parsing
(defun ece-tempel--templates-file-read ()
  (let ((res '()))
    (dolist (metatemps (tempel--file-read ece--templates-file))
      (let ((modes (car metatemps))
            (plist (cadr metatemps))
            (temps (cddr metatemps)))
        (when (tempel--condition-p modes plist)
          (setq res (append res temps)))))
    res))


;;; Keymap
(defvar-keymap ece-template-map
  :doc "Keymap for EasyCrypt templates."
  :prefix 'ece-template-map-prefix)

(dolist (keytemp ece-tempel-template-map-entries)
  (let ((key (car keytemp))
        (temp (cadr keytemp)))
    (eval `(tempel-key ,key ,temp ece-template-map))))


;;; Setup and teardown
(defun ece-tempel--enable-templates ()
  (add-to-list 'tempel-user-elements #'ece-tempel--include)
  (add-to-list 'tempel-template-sources #'ece-tempel--templates-file-read)
  (when tempel-abbrev-mode
    (tempel-abbrev-mode 1))
  (keymap-set easycrypt-ext-mode-map ece-tempel-template-map-prefix 'ece-template-map-prefix))

(defun ece-tempel--disable-templates ()
  (keymap-unset easycrypt-ext-mode-map ece-tempel-template-map-prefix)
  (setq tempel-template-sources
        (remq #'ece-tempel--templates-file-read tempel-template-sources))
  (setq tempel-user-elements (remq #'ece-tempel--include tempel-user-elements))
  (when tempel-abbrev-mode
    (tempel-abbrev-mode 1)))

;;;###autoload
(defun easycrypt-ext-mode-tempel-setup ()
  "Sets up (and tears down) `tempel' integration for `easycrypt-ext-mode'.

Meant for `easycrypt-ext-mode-hook'."
  (if easycrypt-ext-mode
      (ece-tempel--enable-templates)
    (unless (ece--check-other-buffers-mode 'easycrypt-ext-mode)
      (ece-tempel--disable-templates))))


(provide 'easycrypt-ext-tempel)

;;; easycrypt-ext-tempel.el ends here
