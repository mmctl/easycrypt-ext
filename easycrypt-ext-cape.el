;;; easycrypt-ext-cape.el --- Cape Integration for EasyCrypt Ext -*- lexical-binding: t; -*-
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

;; Package-Requires: ((emacs "29.1") (cape "2.1") (easycrypt-ext))

;;; Commentary:
;; Cape integration for EasyCrypt Ext, enabling keyword completion.
;; Keywords are defined in `easycrypt-ext-consts.el'.

;; For setup and usage instructions, see the README at
;; https://github.com/mmctl/easycrypt-ext

;; For more information on Cape, visit
;; https://github.com/minad/cape

;;; Code:

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
    (unless (ece--check-other-buffers-mode 'easycrypt-ext-mode)
      (ece-cape--disable-keyword-completion))))


(provide 'easycrypt-ext-cape)

;;; easycrypt-ext-cape.el ends here
