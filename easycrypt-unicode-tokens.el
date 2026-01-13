;;; easycrypt-unicode-tokens.el --- Unicode-Tokens Integration for EasyCrypt -*- lexical-binding: t; -*-
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

;; Package-Requires: ((emacs "29.1"))

;;; Commentary:
;; EasyCrypt definitions for use with
;; `proof-unicode-tokens.el'/`unicode-tokens.el', libraries provided by Proof
;; General to support unicode symbol input even when the proof assistant does
;; not accept these tokens (i.e., display unicode symbols but store "regular"
;; character sequence understood by proof assistant).
;;
;; For setup and usage instructions, see the README at
;; https://github.com/mmctl/easycrypt-ext

;;; Code:
