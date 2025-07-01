;;; easycrypt-ext.el --- EasyCrypt Extensions (for Proof General) -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2025 Matthias Meijers

;; Author: Matthias Meijers <kernel@mmeijers.com>
;; Maintainer: Matthias Meijers <kernel@mmeijers.com>
;; Created: 22 April 2025

;; Keywords: abbrev, convenience, mouse, tools
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

;; Package-Requires: ((emacs "29.1") (proof-general "4.5"))

;;; Commentary:
;; EasyCrypt is a toolset primarily designed for the formal verification
;; of code-based, game-playing crytpographic proofs. At its core,
;; it features an interactive theorem prover with a front-end implemented
;; in `Proof General'.
;; This package aims to add useful extensions to this EasyCrypt front-end.
;; Key features include the following.
;; - Improved (but still ad-hoc) indentation.
;; - Keyword completion (requires `cape', specifically `cape-keyword').
;; - Code templates (requires `tempel').
;; - Informative templates (requires `tempel').
;; - Executing proof shell commands through keybindings or mouse clicks
;;   (eliminating the need to manually type the corresponding commands).
;;   Supported commands are `print', `search', and `locate'.
;;   This functionality is also made accessible through the
;;   appropriate menus (menu bar and mode line).
;; - Executing command line (sub)commands through keybindings.
;;   Supported commands are `compile', `docgen', `runtest', `why3config',
;;   and `--help' (which is actually an option, but you get the point).
;;   Where relevant, this functionality is extended to the directory/project
;;   level, enabling you to execute a (sub)commands for each EasyCrypt
;;   file in a directory (tree).
;;   This functionality is also made accessible through the
;;   appropriate menus (menu bar and mode line).
;;
;; These features are (partially) implemented through three minor modes, one
;; for each of the major modes provided by the existing front-end:
;; - `easycrypt-ext-mode', for `easycrypt-mode';
;; - `easycrypt-ext-goals-mode', for `easycrypt-goals-mode'; and
;; - `easycrypt-ext-response-mode', for `easycrypt-response-mode'.
;;
;; The default values for the user options are customizable via Emacs's
;; usual customization interface, but all options can additionally
;; be enabled/disabled/toggled via commands accessible through
;; key bindings and the appropriate menus (menu bar and mode line).
;;
;; For setup and usage instructions, see: TODO
;;
;;; Code:

;; Requirements
;; External packages
(require 'proof) ; Provided by proof-general

;; Local
(require 'easycrypt-ext-consts)


;;; Silence, byte compiler
(defvar easycrypt-ext-goals-mode)
(defvar easycrypt-ext-response-mode)
(defvar easycrypt-ext-mode-map)


;;; Constants
(defconst ece--dir
  (file-name-directory (or load-file-name buffer-file-name))
  "Directory where this file is stored (and so also where rest of package should
  be).")

(defconst ece--templates-file
  (expand-file-name "easycrypt-ext-templates.eld" ece--dir)
  "File where code templates for EasyCrypt are stored.")

(defconst ece--templates-info-file
  (expand-file-name "easycrypt-ext-templates-info.eld" ece--dir)
  "File where informative code templates for EasyCrypt are stored.")


;;; Customization options
(defgroup easycrypt-ext nil
  "Customization group for EasyCrypt extension package."
  :prefix "ece-"
  :group 'easycrypt)

(defcustom ece-indentation t
  "Non-nil (resp. `nil') to enable (resp. disable) enhanced
(but still ad-hoc) indentation in EasyCrypt."
  :type 'boolean
  :group 'easycrypt-ext)

(defcustom ece-indentation-style 'local
  "\='local or \='nonlocal to make local or non-local
the default indentation style. The difference between the
two styles mainly pertains to indentation inside
enclosed expressions (e.g., between { and }, ( and ),
or [ and ]): \='local indents w.r.t. previous
non-blank line in the expression; \='non-local indents
w.r.t. expression opener (e.g., { or ( or [).
In any case, indentation using the opposite style is available
through the command `ece-indent-for-tab-command-inverse-style', which see.
Only has effect if `ece-indentation', which see, is non-nil."
  :type '(choice
          (const :tag "Local indentation style" local)
          (const :tag "Non-local indentation style" nonlocal))
  :group 'easycrypt-ext)

(defcustom ece-keyword-completion nil
  "Non-nil (resp. nil) to enable (resp. disable) completion for
EasyCrypt keywords (depends on `cape')."
  :type 'boolean
  :group 'easycrypt-ext)

(defcustom ece-templates nil
  "Non-nil (resp. `nil') to enable (resp. disable) code templates for
EasyCrypt (depends on `tempel'). If you enable this, it is recommended to
also enable enhanced indentation (see `ece-indentation'),
since the templates use indentation and were made with the enhanced
EasyCrypt indentation in mind."
  :type 'boolean
  :group 'easycrypt-ext)

(defcustom ece-templates-info 'ece-templates
  "Non-nil (resp. `nil') to enable (resp. disable) informative code templates
for EasyCrypt (depends on `tempel'). If you enable this, it is recommended to
also enable enhanced indentation (see `ece-indentation'), since the templates
use indentation and were made with the enhanced EasyCrypt indentation in mind."
  :type 'boolean
  :group 'easycrypt-ext)

(defcustom ece-templates-bound
  '(("a" axiomn) ("A" abbrevn) ("b" byequiv) ("B" byphoare)
    ("c" conseq) ("C" conseqeqvhoahoa) ("d" doccommentn) ("D" declaremodule)
    ("e" equivn) ("E" equivnlemman) ("f" funn) ("F" fel)
    ("g" ge0) ("G" gt0) ("h" hoaren) ("H" hoarenlemman)
    ("i" ifelse) ("I" ifthenelse) ("l" lemman) ("L" letinn)
    ("m" module) ("M" modulept) ("o" op) ("O" opas)
    ("p" proc) ("P" procsig) ("r" rewrited) ("R" rngin)
    ("s" seq) ("S" seqph) ("t" moduletype) ("T" moduletypep)
    ("u" Prmbnd) ("U" Prmrbnd) ("v" Prmeq) ("V" Prmreq)
    ("w" whiles) ("W" whileph) ("x" cloneimportaswith) ("X" requireimport)
    ("y" phoaren) ("Y" phoare1n) ("z" theory) ("Z" abstracttheory))
  "Alist of (KEY TEMPLATE-NAME) pairs for which KEY
should be bound to TEMPLATE-NAME in `ece-template-map'
when templates are enabled (i.e., when `ece-templates'
are non-nil). KEY should be a string satisfying
`key-valid-p', which see, and TEMPLATE-NAME should be
a symbol matching a template specified in the template file
`eascyrypt-ext-templates'."
  :type '(alist :key-type key :value-type symbol)
  :group 'easycrypt-ext)

(defcustom ece-exec-runtest-default-test-file "tests.config"
  "Default file name to consider for test configuration files
used with EasyCrypt's `runtest' subcommand. These should be relative
paths, and they are interpreted at runtime with respect to the
considered directory (either provided or whatever `default-directory'
contains at that time)."
  :type 'string
  :group 'easycrypt-ext)

(defcustom ece-exec-runtest-default-scenario "default"
  "Default scenario name (inside test configuration files)
used with EasyCrypt's `runtest' subcommand."
  :type 'string
  :group 'easycrypt-ext)

(defcustom ece-exec-runtest-default-report-file "report.log"
  "Default file name for the report used with EasyCrypt's `runtest'
subcommand. This should be a relative path, and it is
interpreted at runtime with respect to the considered
directory (either provided or whatever `default-directory'
contains at that time)."
  :type 'string
  :group 'easycrypt-ext)

(defcustom ece-exec-docgen-default-outdir "docs/"
  "Default output directory used with EasyCrypt's `docgen'
subcommand to store the generated documentation.
This should be a relative path, and it is
interpreted at runtime with respect to the considered directory
(either provided or whatever `default-directory'
contains at that time)."
  :type 'string
  :group 'easycrypt-ext)


;;; Utilities
(defsubst ece--check-feature (feature)
  (unless (featurep feature)
    (user-error "Feature `%s' not detected, but required. Try again after loading" (symbol-name feature))))

(defsubst ece--check-functionality (fun feature)
  (unless (fboundp fun)
    (user-error "Function `%s' from feature `%s' not detected, but required. Make sure to load the feature"
                (symbol-name fun)
                (symbol-name feature))))

(defsubst ece--check-other-buffers-mode (mode)
  (seq-some #'(lambda (buf)
                (and (not (eq buf (current-buffer)))
                     (with-current-buffer buf (symbol-value mode))))
            (buffer-list)))

(defun ece--gen-buffer-loop-pred (fun pred &optional args)
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (or (null pred) (funcall pred))
        (apply fun args)))))

(defun ece--gen-buffer-loop-symb (fun symb &optional args)
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (symbol-value symb)
        (apply fun args)))))

(defsubst ece--ece-configure-global-from-local (fun &optional args)
  (ece--gen-buffer-loop-symb fun 'easycrypt-ext-mode args))


;;; Indentation
(defun ece--insert-tabs-of-whitespace (n)
  "Insert N literal tabs worth of whitespace, respecting `indent-tabs-mode'."
  (if indent-tabs-mode
      ;; Then, insert N actual tab characters
      (insert (make-string n ?\t))
    ;; Else, insert N * `tab-width' spaces
    (insert (make-string (* n tab-width) ?\s))))

;; Basic indentation
;;;###autoload
(defun ece-basic-indent (arg)
  "Indent (ARG > 0) resp. de-indent (ARG < 0) all lines touched by the
active region by |ARG| tab stops.
If no region is active and point is inside indentation,
then indent (ARG > 0) resp. de-indent (ARG < 0) current line |ARG| times
(respecting tab stops).
If no region is active and point is in the middle of a line, insert (ARG > 0)
or delete (ARG < 0) literal whitespace (|ARG| * `tab-width' worth).
If ARG < 0 and there is no whitespace behind point in the middle of a line,
again de-indent line |ARG| times (respecting tab stops)."
  (interactive "p")
  (let* ((neg (< arg 0))
         (count (if neg (abs arg) arg))
         (orig-point (point))
         (orig-col (current-column))
         (orig-ind (current-indentation)))
    ;; If region is active,...
    (if (use-region-p)
        ;; Then, store start position of point and compute indentation region
        (let ((ind-region-start (save-excursion (goto-char (region-beginning))
                                                (pos-bol)))
              (ind-region-stop (save-excursion (goto-char (region-end))
                                               (when (bolp) (forward-line -1))
                                               (pos-eol))))
          ;; If it is inside region to indent within margins of indentation,
          ;; move to (end of) indentation
          ;; (Otherwise, leave point as is)
          (cond
           ;; If point is before start of region to indent...
           ((< orig-point ind-region-start)
            ;; Then, move it to indentation on first line of region to indent
            (goto-char ind-region-start)
            (back-to-indentation))
           ;; Else, if point is after end of region to indent...
           ((< ind-region-stop orig-point)
            ;; Then, move it to indentation on last line of region to indent
            (goto-char ind-region-stop)
            (back-to-indentation))
           ;; Else (point is inside region to indent), move it to indentation of current line
           ((< orig-col orig-ind)
            (back-to-indentation)))
          ;; Indent indentation region appropriately
          (if neg
              (dotimes (_ count) (indent-rigidly-left-to-tab-stop ind-region-start ind-region-stop))
            (dotimes (_ count) (indent-rigidly-right-to-tab-stop ind-region-start ind-region-stop)))
          ;; Don't deactivate-mark, so we don't have to re-select region to repeat
          (setq-local deactivate-mark nil))
      ;; Else (no region is active), if line is empty...
      (if (string-match-p "^[[:blank:]]*$" (buffer-substring-no-properties (pos-bol) (pos-eol)))
          ;; Then, if ARG < 0...
          (if neg
              ;; Then, remove (at most) |ARG| tabs worth of whitespace before point
              (delete-region (max (pos-bol) (- orig-point (* count tab-width))) orig-point)
            ;; Else, simply insert ARG tabs worth of whitespace
            (ece--insert-tabs-of-whitespace count))
        ;; Else (line is not empty), if inside indentation...
        (if (<= orig-col orig-ind)
            ;; Then, (de-)indent current line (at most) |ARG| times (and move to indentation)
            (progn
              (if neg
                  (dotimes (_ count) (indent-rigidly-left-to-tab-stop (pos-bol) (pos-eol)))
                (dotimes (_ count) (indent-rigidly-right-to-tab-stop (pos-bol) (pos-eol))))
              (back-to-indentation))
          ;; Else (line is not empty and not inside indentation), if ARG < 0...
          (if neg
              ;; Then, take stock of whitespace before point...
              (let* ((del-ub (min (* count tab-width) (- orig-point (pos-bol))))
                     (del (save-excursion
                            (skip-chars-backward "[:space:]" (- orig-point del-ub))
                            (- orig-point (point)))))
                ;; If there is at least some whitespace before point...
                (if (< 0 del)
                    ;; Then, delete |ARG| * tab-width worth of whitespace
                    ;; (at most, until first non-whitespace character)
                    (delete-region (- orig-point del) orig-point)
                  ;; Else, de-indent current line (at most) |ARG| times
                  (dotimes (_ count) (indent-rigidly-left-to-tab-stop (pos-bol) (pos-eol)))))
            ;; Else (ARG >= 0), simply insert ARG tabs worth of whitespace
            (ece--insert-tabs-of-whitespace count)))))))

;;;###autoload
(defun ece-basic-deindent (arg)
  "Passes negation of ARG to `ece-basic-indent', which see."
  (interactive "p")
  (ece-basic-indent (- arg)))

;; Contextual indentation
(defun ece--goto-previous-nonblank-line ()
  "Moves point to start of previous non-blank line,
or beginning of buffer if there is no such line."
    (forward-line -1)
    (while (and (not (bobp)) (looking-at-p "^[[:blank:]]*$"))
      (forward-line -1)))

(defun ece--indent-level-fallback ()
  "Returns fallback indentation level for EasyCrypt code (i.e., when no `special
indentation' case is detected). In short, the behavior is as follows. If
previous non-blank line start with a proof bullet (i.e., `+', `-', or `*'),
indent as to put point after proof bullet. Else, if the previous non-blank line
is an unfinished non-proof/non-code specification (e.g., starts with `lemma' but
does not end with a `.'), indent 1 tab further than that line. Else, align with
previous non-blank line."
  (save-excursion
    ;; Go to (indentation of) previous non-blank line
    (ece--goto-previous-nonblank-line)
    (back-to-indentation)
    ;; If previous non-blank line is outside any special construct
    ;; (e.g., comments, strings, and enclosed expressions)
    ;; and starts with a proof bullet (i.e., `+', `-', or `*'),
    (if-let* ((synps (syntax-ppss))
              ((null (nth 1 synps)))
              ((null (nth 3 synps)))
              ((null (nth 4 synps)))
              ((memq (char-after) ece-bullets-proof)))
        ;; Then, align to that line + 2 (putting point right after bullet)
        (+ (current-indentation) 2)
      ; Else, get content of that line...
      (let ((prev-line (buffer-substring-no-properties (pos-bol) (pos-eol))))
        ;; If that line is an unfinished non-proof/non-proc spec
        ;; (E.g., starts with `lemma' but does not end with a `.')
        ;; Here, we also count a comma as ending a spec to deal with the case of
        ;; instantiation in `clone' (and hope it isn't common to end a line
        ;; with a comma outside of `clone').
        (if (and (seq-some (lambda (kw)
                             (string-match-p (format "^[[:blank:]]*%s\\b" (regexp-quote kw)) prev-line))
                           ece-keywords-start)
                 (not (string-match-p "[\\.,][[:blank:]]*\\(?:(\\*.*\\*)\\)?[[:blank:]]*$" prev-line)))
            ;; Then, align with that line + tab
            (+ (current-indentation) tab-width)
          ;; Else, align with that line (default)
          (current-indentation))))))

(defun ece--indent-level ()
  "Returns desired indentation level of EasyCrypt code.
In short, the default behavior is as follows.
- If we are in a multi-line comment, align with the previous non-blank line in
comment if it exists; otherwise, indent 1 tab beyond comment opener.
- Else, if we are in a multi-line string, remove indentation (because it
affects the value of the string).
- Else, if we are in an non-code expression (i.e., between `(' and `)' or
`[' and `]', or after `(' or `[' without a corresponding closer),
align with the previous non-blank line in expression if it exists; otherwise,
indent 1 space beyond expression opener.
- Else, if we are in a code expression (i.e., between `{' and `}', or after
`{' without a corresponding closer), align with the previous non-blank line
in code block if it exists; otherwise, indent 1 tab beyond the line that
started the specification corresponding to the code block (e.g., the line
that starts with `module' or `proc'.
- Else, if we are opening a proof (e.g., our line starts with `proof' or
`realize'), align to line that started the proof statement specification
(e.g., the line starting with `lemma'); if we cannot find such a line,
use fallback indentation.
- Else, if we are closing a proof (e.g., our line starts with `qed'), align to
line that opened the proof (e.g., the previous line starting with `proof'); if
we cannot find such a line, use fallback indentation.
- Else, use fallback indentation.
Here, fallback indentation refers to the indentation computed by
`ece--indent-level-fallback', which see."
  (let ((indent-level 0))
    (save-excursion
      ;; Base decision on context of line's first non-whitespace character
      ;; (or beginning of line if empty)
      (back-to-indentation)
      (let* ((synps (syntax-ppss))
             (exprop (nth 1 synps))
             (instr (nth 3 synps))
             (incom (nth 4 synps))
             (csop (nth 8 synps)))
        (cond
         ;; If we are in a comment...
         (incom
          (let ((comcl (looking-at-p (regexp-opt ece-delimiters-comments-close)))
                (opcol (save-excursion (goto-char csop) (current-column))))
            ;; Then, if our line closes the comment...
            (if (and incom comcl)
                ;; Then, align closer with the opener
                (setq indent-level opcol)
              ;; Else, if indentation style is non-local...
              (if (eq ece-indentation-style 'nonlocal)
                  ;; Then, align to opener + tab
                  (setq indent-level (+ opcol tab-width))
                ;; Else (indentation style is local)...
                (ece--goto-previous-nonblank-line) ; Go to beginning of previous non-blank line
                ;; If there is a previous non-blank line inside comment...
                (if (< (line-number-at-pos csop) (line-number-at-pos))
                    ;; Then, align to that line
                    (setq indent-level (current-indentation))
                  ;; Else, align to opener + tab
                  (setq indent-level (+ opcol tab-width)))))))
         ;; Else, if we are in a string...
         (instr
          ;; Then, set indent-level to 0 (because indentation affects value of string)
          (setq indent-level 0))
         ;; Else, if we are in an opened or enclosed expression...
         ;; E.g., between { and }, or ( and ), or after { with no closing counterpart
         (exprop
          (let* ((chcl (char-after))
                 (choci (save-excursion
                          (goto-char exprop)
                          (list (char-after) (current-column) (current-indentation))))
                 (chop (nth 0 choci))
                 (opcol (nth 1 choci))
                 (opind (nth 2 choci)))
              ;; Then, if opener is an expression opener (`[` or `(`)...
              (if (memq chop ece-delimiters-expression-open)
                  ;; Then, if first char on our line is a matching closer...
                  (if (eq chcl (matching-paren chop))
                      ;; Then, align to column of opener
                      (setq indent-level opcol)
                    ;; Else, if indentation style is non-local...
                    (if (eq ece-indentation-style 'nonlocal)
                        ;; Then, align to opener + 1
                        (setq indent-level (+ opcol 1))
                      ;; Else (indentation style is local)...
                      (ece--goto-previous-nonblank-line) ; Go to beginning of previous non-blank line
                      ;; If there is previous non-blank line in the enclosed expression...
                      (if (< (line-number-at-pos exprop) (line-number-at-pos))
                          ;; Then, align to that line
                          (setq indent-level (current-indentation))
                        ;; Else, align to opener + 1
                        (setq indent-level (+ opcol 1)))))
                ;; Else, if opener is a code opener (i.e., `{`)...
                (if (memq chop ece-delimiters-code-open)
                    ;; Then,...
                    (let ((bob nil))
                      (progn
                        ;; Find "imperative spec starter" (i.e., a keyword
                        ;; opening a code block, like module or proc) or
                        ;; "scoper" (i.e., keyword defining the scope of an
                        ;; artifact, like local, global, or declare)
                        (save-excursion
                          (goto-char exprop)
                          (forward-line 0)
                          (while (and (not (bobp))
                                      (not (seq-some (lambda (kw) (looking-at-p (format "^[[:blank:]]*%s\\b" (regexp-quote kw))))
                                                     ece-keywords-imperative-spec-start-scope)))
                            (forward-line -1))
                          ;; If we didn't find such a line (i.e., we are at the beginning of a buffer)...
                          (if (bobp)
                              ;; Then, record this fact
                              (setq bob t)
                            ;; Else, record indentation of keyword's line
                            (setq indent-level (current-indentation))))
                        ;; If we didn't find a valid keyword,...
                        (if bob
                            ;; Then, fallback to indenting relative to opening brace instead
                            ;; So, if first char on our line is a matching closing brace...
                            (if (eq chcl (matching-paren chop))
                                ;; Then, align to indentation of opening brace's line
                                (setq indent-level opind)
                              ;; Else, if indentation style is non-local...
                              (if (eq ece-indentation-style 'nonlocal)
                                  ;; Then, align to indentation of opening brace's line + tab
                                  (setq indent-level (+ opind tab-width))
                                ;; Else (indentation style is local)...
                                (ece--goto-previous-nonblank-line) ; Go to beginning of previous non-blank line
                                ;; If there is previous non-blank line in the enclosed expression...
                                (if (< (line-number-at-pos exprop) (line-number-at-pos))
                                    ;; Then, align to that line
                                    (setq indent-level (current-indentation))
                                  ;; Else, align to indentation of opening brace's line + tab
                                  (setq indent-level (+ opind tab-width)))))
                          ;; Else (we found a valid keyword and `indent-level` recorded
                          ;; indentation of corresponding line),
                          ;; if first char on our line is *not* a matching closer...
                          (unless (eq chcl (matching-paren chop))
                            ;; Else, if indentation style is non-local...
                              (if (eq ece-indentation-style 'nonlocal)
                                  ;; Then, align to recorded indentation of keyword's line + tab
                                  (setq indent-level (+ indent-level tab-width))
                                ;; Else (indentation style is local)...
                                (ece--goto-previous-nonblank-line) ; Go to beginning of previous non-blank line
                                ;; If there is previous non-blank line in the enclosed expression...
                                (if (< (line-number-at-pos exprop) (line-number-at-pos))
                                    ;; Then, align to that line
                                    (setq indent-level (current-indentation))
                                  ;; Else, align to recorded indentation of keyword's line + tab
                                  (setq indent-level (+ indent-level tab-width))))))))
                  ;; Else, parsing indicates we are in an expression that has
                  ;; an unknown opener, which shouldn't be possible.
                  ;; Although this is a bug and should be fixed, don't annoy user
                  ;; by throwing an error. Instead, log and use fallback.
                  (message "%s %s %s"
                           "ece--indent-level: parsing indicates expression with unknown delimiter."
                           "This should not be possible, please report."
                           "Using fallback indentation.")
                  (setq indent-level (ece--indent-level-fallback))))))
         ;; Else, if we are looking at a terminated proof starter (e.g., "proof." or "realize.")
         ((seq-some (lambda (kw) (looking-at-p (format "%s\\." (regexp-quote kw))))
                    ece-keywords-proof-start)
          (let ((bob nil))
            (progn
              (save-excursion
                ;; Find previous "proof spec starter" (i.e., keyword starting a
                ;; lemma such as lemma, hoare (without following [), and
                ;; equiv (without following [)
                (forward-line -1)
                (while (and (not (bobp))
                            (not (seq-some
                                  (lambda (kw)
                                    (and (looking-at-p (format "^[[:blank:]]*%s\\b" (regexp-quote kw)))
                                         (not (looking-at-p (format "^[[:blank:]]*%s\\b[[:space:]]*\\[" (regexp-quote kw))))))
                                  ece-keywords-proof-spec-start)))
                  (forward-line -1))
                ;; If we didn't find such a line (i.e., we are at the beginning of a buffer)...
                (if (bobp)
                    ;; Then, record this fact
                    (setq bob t)
                  ;; Else, align to indentation of proof spec starter
                  (setq indent-level (current-indentation))))
              ;; If we didn't find a proof spec starter
              (when bob
                ;; Indent as per the fallback
                (setq indent-level (ece--indent-level-fallback))))))
         ;; Else, if we are looking at a terminated proof ender (i.e., "qed.")
         ((seq-some (lambda (kw) (looking-at-p (format "%s\\." (regexp-quote kw))))
                    ece-keywords-proof-end)
          (let ((bob nil))
            (progn
              (save-excursion
                ;; Find line that started the proof (i.e., one that starts with "proof")
                (forward-line -1)
                (while (and (not (bobp))
                            (not (seq-some (lambda (kw) (looking-at-p (format "^[[:blank:]]*%s\\b" (regexp-quote kw))))
                                           ece-keywords-proof-start)))
                  (forward-line -1))
                ;; If we didn't find such a line (i.e., we are at the beginning of a buffer)...
                (if (bobp)
                    ;; Then, record this fact
                    (setq bob t)
                  ;; Else, align to indentation of proof starter
                  (setq indent-level (current-indentation))))
              ;; If we didn't find a proof starter
              (when bob
                ;; Indent as per the fallback
                (setq indent-level (ece--indent-level-fallback))))))
         ;; Else,...
         (t
          ;; Indent as per the fallback
          (setq indent-level (ece--indent-level-fallback))))))
    indent-level))

;;;###autoload
(defun ece-indent-line ()
  "Indents line of EasyCrypt code as per `ece--indent-level', which see."
  (interactive)
  ;; Indent accordingly
  (let ((indent-level (ece--indent-level)))
    ;; `indent-line-to' would move point to new indentation, and
    ;; we prevent this by `save-excursion' so point position remains consistent
    ;; (making templates more consistent as well)
    (save-excursion
      (indent-line-to indent-level))
    ;; Still adjust point if it's inside indentation
    (when (< (current-column) (current-indentation))
      (back-to-indentation))))

;;;###autoload
(defun ece-indent-for-tab-command-inverse-style ()
  "Calls `indent-for-tab-command' with `ece-indentation-style' inverted.
If `ece-indentation' is non-nil, `indent-line-function' will be set to
`ece-indent-line', which is used by `indent-for-tab-command' to indent a line
or region. So, this command essentially performs indentation according to the
style that is currently not selected."
  (interactive)
  (let ((ece-indentation-style (if (eq ece-indentation-style 'local) 'nonlocal 'local)))
    (indent-for-tab-command)))

;;;###autoload
(defun ece-indent-on-insertion-closer ()
  "Indent when (1) last input was one of }, ), ], and it is the
first character on current line (as an exception, `)` may also directly
be preceded by symbols that make it a comment closer), or (2) the last
input was . and the current line starts/ends a proof. However, only
allow de-indents (to prevent automatically indenting
code that has been manually de-indented; this is a hack
and a limitation of the localized ad-hoc computation
of the indent level).
Meant for `post-self-insert-hook'."
  (when-let* ((line-before (buffer-substring-no-properties (pos-bol) (- (point) 1)))
              ((or (and (memq last-command-event '(?\} ?\]))
                        (string-match-p "^[[:blank:]]*$" line-before))
                   (and (eq last-command-event ?\))
                        (string-match-p
                         (format "^[[:blank:]]*%s$" (regexp-opt (push (string ?\)) ece-delimiters-comments-close)))
                         (concat line-before ")")))
                   (and (eq last-command-event ?\.)
                        (save-excursion
                          (back-to-indentation)
                          (seq-some (lambda (kw) (looking-at-p (format "%s\\b" (regexp-quote kw))))
                                    ece-keywords-proof-delimit)))))
              (orig-col (current-column))
              (indent-level (ece--indent-level))
              (indent-diff (- (current-indentation) indent-level)))
    ;; If 0 < indent-diff, i.e., we are de-indenting...
    (when (< 0 indent-diff)
      ;; Go to the computed indent level...
      (indent-line-to indent-level)
      ;; And keep point in same relative position
      ;; (`indent-line-to' moves it to end of indentation)
      (move-to-column (- orig-col indent-diff)))))

;;;###autoload
(defun ece-indent-closer-on-insertion-newline ()
  "Indent previous line when (1) last input was a newline, and (2)
it only contains a code, expression, or comment closer (the former two
may potentially be followed by a period). However, only
allow de-indents (to prevent automatically indenting
code that has been manually de-indented; this is a hack
and a limitation of the localized ad-hoc computation
of the indent level).
Meant for `post-self-insert-hook'."
  (when (eq last-command-event 10) ; 10 = newline
    (save-excursion
      (forward-line -1)
      (when-let* (((or (looking-at-p (format "^[[:blank:]]*%s$" (regexp-opt ece-delimiters-comments-close)))
                       (looking-at-p (format "^[[:blank:]]*%s\\.?$"
                                             (regexp-opt (mapcar #'string
                                                                 (append ece-delimiters-code-close
                                                                         ece-delimiters-expression-close)))))
                       (looking-at-p (format "^[[:blank:]]*%s\\.$" (regexp-opt ece-keywords-proof-delimit)))))
                  (indent-level (ece--indent-level))
                  ((< 0 (- (current-indentation) indent-level)))) ; If we are de-indenting...
        ;; Go to the computed indent level...
        (indent-line-to indent-level)))))


;;; Proof shell commands
(defconst ece--proofshell-supported-commands
  '("locate" "pragma" "print" "search")
  "List of currently supported (proof shell) commands")

(defun ece--proofshell-validate-command (command)
  "Checks if the COMMAND is a valid/supported EasyCrypt proof shell command
(in the sense that a command below is implemented for it)."
  (or (member command ece--proofshell-supported-commands)
      (error "Unknown/Unsupported proof command: `%s'" command)))

(defun ece--proofshell-execute (command &optional args sync callback)
  "Combines COMMAND and ARGS into a command for the EasyCrypt proof shell, and
directly calls the shell with it. If SYNC is non-nil (resp. `nil'), the process
is executed synchronously (resp. asynchronously). ARGS is a string that is
concatenated to SUBCOMMAND (separated by a space) as is."
  (unless (or (null args) (stringp args))
    (error "ece--proofshell-execute: ARGS (%s) should be nil or a string" args))
  (ece--check-functionality 'proof-shell-invisible-command 'proof-general)
  ;; proof-shell-ready-prover called inside proof-shell-invisible-command
  (let ((cmd (if args (concat command  " " args) command)))
    (proof-shell-invisible-command cmd sync callback)))

;; Prompted
(defun ece--proofshell-prompt-command (command &optional collection sync callback)
  "Prompts user for arguments that are passed to COMMAND (proof shell) command
of EasyCrypt. If COLLECTION is non-nil, it should be a valid second argument
to `completing-read', which see. It represents the possible
arguments for the command, and completion functionality is provided for
these."
  (when (ece--proofshell-validate-command command)
    (let ((args (if collection
                    (completing-read (format-prompt "Argument for `%s'" nil command)
                                     collection nil t)
                  (read-string (format-prompt "Provide arguments for `%s'" nil command)))))
      (if args
          (ece--proofshell-execute command (when (not (string-empty-p args)) args)
                                   sync callback)
        (user-error "Please provide an argument")))))

;;;###autoload
(defun ece-proofshell-prompt-pragma ()
  "Prompts user for arguments that are passed to the `pragma' (proof shell)
command of EasyCrypt."
  (interactive)
  (ece--proofshell-prompt-command "pragma" ece-pragmas))

;;;###autoload
(defun ece-proofshell-prompt-print ()
  "Prompts user for arguments that are passed to the `print' (proof shell)
command of EasyCrypt."
  (interactive)
  (ece--proofshell-prompt-command "print"))

;;;###autoload
(defun ece-proofshell-prompt-search ()
  "Prompts user for arguments that are passed to the `search' (proof shell)
command of EasyCrypt."
  (interactive)
  (ece--proofshell-prompt-command "search"))

;;;###autoload
(defun ece-proofshell-prompt-locate ()
  "Prompts user for arguments that are passed to the `locate' (proof shell)
command of EasyCrypt."
  (interactive)
  (ece--proofshell-prompt-command "locate"))

;;;###autoload
(defun ece-proofshell-prompt (command)
  "Entry point for executing any of the supported (proof shell) commands,
with prompt, as defined in `ece--proofshell-supported-commands'. Provides
completion for the possible candidates, and directly dispatches the command
corresponding to the choice upon confirmation."
  (interactive (list
                (completing-read (format-prompt "Command" ece--proofshell-supported-commands)
                                 ece--proofshell-supported-commands nil t nil nil
                                 ece--proofshell-supported-commands)))
  (call-interactively (intern-soft (format "ece-proofshell-prompt-%s" command))))

;; Non-prompted (based point location or mouse click)
(defun ece--thing-at (event)
  "If EVENT is a mouse event, tries to find a (reasonable) thing at mouse
(ignoring any active region). Otherwise, takes the active region
or tries to find a (reasonable) thing at point."
  (if (mouse-event-p event)
      (or (thing-at-mouse event 'symbol t)
          (thing-at-mouse event 'sexp t)
          (thing-at-mouse event 'word t))
    (if (use-region-p)
        (prog1
            (buffer-substring-no-properties (region-beginning) (region-end))
          ;; HACK: This prevents the whole buffer being marked
          ;; in the goals/response buffers when issuing commands
          ;; (at least those that update the response buffer)
          ;; Better solution would, e.g., be to try and use some
          ;; provided PG hooks for remarking region if applicable
          (when (or easycrypt-ext-goals-mode easycrypt-ext-response-mode)
            (deactivate-mark)))
      (or (thing-at-point 'symbol t)
          (thing-at-point 'sexp t)
          (thing-at-point 'word t)))))

(defun ece--command (command event)
  "If EVENT is a mouse event, tries to find a (reasonable) thing at mouse
(ignoring any active region). Otherwise, takes the active region or tries to
find a (reasonable) thing at point. The result is used as an argument to the
COMMAND command of EasyCrypt. If nothing (reasonable) is found, prints a message
informing the user."
  (when (ece--proofshell-validate-command command)
    (let ((arg (ece--thing-at event)))
      (if arg
          (ece--proofshell-execute command arg)
        (user-error "No reasonable thing at %s found for command `%s'%s"
                    (if (mouse-event-p event) "mouse" "point")
                    command
                    (if (mouse-event-p event) "" ". Try selecting the thing if automatic detection doesn't work"))))))

;;;###autoload
(defun ece-proofshell-print (&optional event)
  "If EVENT is a mouse event, tries to find a (reasonable) thing at mouse
(ignoring any active region). Otherwise, takes the active region
or tries to find a (reasonable) thing at point. Uses the result as an
argument to the `print' command in EasyCrypt."
  (interactive (list (if (mouse-event-p last-input-event)
                         last-input-event
                       nil)))
  (ece--command "print" event))

;;;###autoload
(defun ece-proofshell-search (&optional event)
  "If EVENT is a mouse event, tries to find a (reasonable) thing at mouse
(ignoring any active region). Otherwise, takes the active region
or tries to find a (reasonable) thing at point. Uses the result as an
argument to the `search' command in EasyCrypt."
  (interactive (list (if (mouse-event-p last-input-event)
                         last-input-event
                       nil)))
  (ece--command "search" event))

;;;###autoload
(defun ece-proofshell-locate (&optional event)
  "If EVENT is a mouse event, tries to find a (reasonable) thing at mouse
(ignoring any active region). Otherwise, takes the active region
or tries to find a (reasonable) thing at point. Uses the result as an
argument to the `locate' command in EasyCrypt."
  (interactive (list (if (mouse-event-p last-input-event)
                         last-input-event
                       nil)))
  (ece--command "locate" event))

;;;###autoload
(defun ece-bufhist-prev (&optional n)
  "Browses back N buffer history items (for the
goals and response buffer) by wrapping `bufhist-prev',
which see. Allows binding to a mouse-based key
(e.g., `<wheel-up>') and have it effect the window
that the mouse is hovering, not necessarily the active one."
  (interactive "@")
  (ece--check-functionality 'bufhist-prev 'proof-general)
  (bufhist-prev n))

(defun ece-bufhist-next (&optional n)
  "Browses back N buffer history items (for the
goals and response buffer) by wrapping `bufhist-next',
which see. Allows binding to a mouse-based key
(e.g., `<wheel-down>') and have it effect the window
that the mouse is hovering, not necessarily the active one."
  (interactive "@")
  (ece--check-functionality 'bufhist-next 'proof-general)
  (bufhist-next n))


;;; Executable (sub)commands
(defconst ece--exec-supported-subcommands
  '("compile" "docgen" "runtest" "why3config" "--help")
  "List of currently supported (executable) subcommands")

(defun ece--exec-validate-subcommand (subcommand)
  "Checks if SUBCOMMAND is a valid/supported subcommand
for EasyCrypt (executable, not proof shell)."
  (or (member subcommand ece--exec-supported-subcommands)
      (error "Unknown/Unsupported subcommand `%s'" subcommand)))

(defun ece--insert-command-header-in-buffer (buffer command)
  (with-current-buffer buffer
    (goto-char (point-max))
    (unless (bobp)
      (newline (if (bolp) 2 3)))
    (insert (format "Executing command `%s'\nCommand output:\n" command))))

;; (defun ece--execute-subcommand (subcommand sync &rest args)
;;   "Executes SUBCOMMAND of EasyCrypt in a separate process. If SYNC is non-nil
;; (resp. `nil'), the process is executed synchronously (resp. asynchronously).
;; ARGS is a list of strings, all of which are combined to form the remainder of
;; the command. That is, this list contains, in order, the elements that are to be
;; space-separated in the command; this includes the option flags."
;;   (unless (bound-and-true-p easycrypt-prog-name)
;;     (user-error "EasyCrypt executable name not found in expected place. Make sure to load Proof General in EasyCrypt mode"))
;;   (ece--exec-validate-subcommand subcommand)
;;   (let* ((bufnm (format "*EasyCrypt subcommand: %s (%s)*" subcommand (if sync "sync" "async")))
;;          (buf (get-buffer-create bufnm))
;;          (fcom (format "%s %s" easycrypt-prog-name (combine-and-quote-strings (cons subcommand args) " "))))
;;     (display-buffer buf)
;;     (if (not sync)
;;         (apply #'start-process fcom buf easycrypt-prog-name subcommand args)
;;       (ece--insert-command-header-in-buffer buf fcom)
;;       (apply #'call-process easycrypt-prog-name nil buf t subcommand args))))

(defun ece--exec-execute (subcommand &optional args sync)
  "Executes SUBCOMMAND of EasyCrypt in a separate process. If SYNC is non-nil
(resp. `nil'), the process is executed synchronously (resp. asynchronously).
ARGS is a string that is concatenated to SUBCOMMAND (separated by a space) as
is."
  (unless (or (null args) (stringp args))
    (error "ece--exec-execute: ARGS (%s) should be nil or a string" args))
  (ece--exec-validate-subcommand subcommand)
  (unless (bound-and-true-p easycrypt-prog-name)
    (user-error "EasyCrypt executable name not found in expected place. Make sure to load Proof General in EasyCrypt mode"))
  (let* ((bufnm (format "*EasyCrypt subcommand: %s (%s)*" subcommand (if sync "sync" "async")))
         (buf (get-buffer-create bufnm))
         (fcom (concat easycrypt-prog-name " " subcommand (when args (format " %s" args))))
         (sargs (when args (split-string-shell-command args))))
    (display-buffer buf)
    (if (not sync)
        (apply #'start-process fcom buf easycrypt-prog-name (cons subcommand sargs))
      (ece--insert-command-header-in-buffer buf fcom)
      (apply #'call-process easycrypt-prog-name nil buf t (cons subcommand sargs)))))

;; Subcommand: compile
(defun ece--exec-compile-internal (srcs &optional subdirs options sync)
  "Executes `easycrypt compile' using `ece--execute-subcommand' (passing
SYNC directly), which see, checking the EasyCrypt file SRCS or, if SRCS
is a directory, EasyCrypt files in (sub-directories of) SRCS. In the
latter case, sub-directories are considered if SUBDIRS is non-nil. SRCS
can be absolute or relative. A relative path (for SRCS) is interpreted
with respect to `default-directory'. OPTIONS, if non-nil, should be a
string and is concatenated to the command as is."
  (unless (or (null options) (stringp options))
    (error "ece--exec-compile-internal: OPTIONS (%s) should be nil or a string" options))
  (let ((esrc (expand-file-name srcs)))
    (unless (file-readable-p esrc)
      (user-error "`%s' (resolved as `%s') non-existent or not readable" srcs esrc))
    (when (and (file-regular-p esrc)
               (not (string-match-p "^[^.].*\\.eca?$" (file-name-nondirectory esrc))))
      (user-error "`%s' (resolved as `%s') not recognized as an EasyCrypt source file: extension should be `.ec' or `.eca'"
                  srcs esrc))
    (cond
     ((file-regular-p esrc)
      (ece--exec-execute "compile"
                         (if (and options (not (string-empty-p options)))
                             (concat esrc " " options)
                           esrc)
                         sync))
     ((and (file-directory-p esrc) (not subdirs))
      (let ((srcl (directory-files esrc t "^[^.].*\\.eca?$")))
        (if srcl
            (dolist (src srcl) (ece--exec-execute "compile"
                                                  (if (and options (not (string-empty-p options)))
                                                      (concat src " " options)
                                                    src)
                                                  sync))
          (user-error "No EasyCrypt source files found in `%s' (resolved as `%s')" srcs esrc))))
     ((and (file-directory-p esrc) subdirs)
      (let ((srcl (directory-files-recursively esrc "^[^.].*\\.eca?$" nil t t)))
        (if srcl
            (dolist (src srcl) (ece--exec-execute "compile"
                                              (if (and options (not (string-empty-p options)))
                                                  (concat src " " options)
                                                src)
                                              sync))
          (user-error "No EasyCrypt source files found in `%s' (resolved as `%s') or its sub-directories" srcs esrc))))
     (t
      (user-error "`%s' (resolved as `%s') not a regular file nor a directory" srcs esrc)))))

;;;###autoload
(defun ece-exec-compile (srcs &optional subdirs options)
  "Executes `easycrypt compile' asynchronously, checking the EasyCrypt file SRCS
or, if SRCS is a directory, EasyCrypt files in (sub-directories of) SRCS. In the
latter case, sub-directories are considered if SUBDIRS is non-nil. SRCS can be
absolute or relative. A relative path (for SRCS) is interpreted with respect to
`default-directory'. OPTIONS, if provided, should be a string and is
concatenated to the command as is."
  (interactive
   (let* ((projcr (project-current))
          (defdir (or (when projcr (file-name-as-directory (expand-file-name (project-root projcr))))
                      default-directory))
          (srcs (read-file-name (format-prompt "EasyCrypt source file or directory" defdir)
                                defdir defdir t))
          (subdirs (when (file-directory-p srcs) (yes-or-no-p "Include sub-directories?")))
          (options (read-string (format-prompt "Further options" ""))))
     (list srcs subdirs (when (not (string-empty-p options)) options))))
   (ece--exec-compile-internal srcs subdirs options))

;;;###autoload
(defun ece-exec-compile-file (file &optional options)
  "Executes `easycrypt compile' asynchronously,
checking the EasyCrypt file FILE which, if relative, is interpreted with
respect to `default-directory'. OPTIONS, if non-nil, should be a string and is
concatenated to the command as is. Interactively, FILE defaults to the
file visited by the current buffer or, if the current buffer is not
visiting such a file, asks to specify a file instead.
Further, interactively, no possibility of specifying OPTIONS is given."
  (interactive
   (let* ((projcr (project-current))
          (defdir (or (when projcr (file-name-as-directory (expand-file-name (project-root projcr))))
                      default-directory))
          (buffn (buffer-file-name))
          (file (if (and buffn (string-match-p "^[^.].*\\.eca?$" (file-name-nondirectory buffn)))
                    buffn
                  (read-file-name (format-prompt "EasyCrypt source file" "")
                                  defdir nil t nil (apply-partially #'string-match-p "^[^.].*\\.eca?$")))))
     (list file nil)))
  (ece--exec-compile-internal file nil options))

;;;###autoload
(defun ece-exec-compile-projdir (root &optional options)
  "Executes `easycrypt compile' command asynchronously, checking the EasyCrypt
files in ROOT, including sub-directories. OPTIONS, if non-nil, should be
a string and is concatenated to the command as is. Interactively,
without a prefix argument, ROOT defaults to the root of the current
project or, if no project is found, asks to provide such a root. With a
prefix argument, ROOT instead defaults to `default-directory' or, if
that does not contain any EasyCrypt source files, asks to provide a root
directory instead. Further, interactively, no possibility of specifying
OPTIONS is given."
  (interactive
   (let* ((projcr (when (null current-prefix-arg) (project-current t)))
          (root (or (when projcr
                      (file-name-as-directory (expand-file-name (project-root projcr))))
                    (when (directory-files-recursively default-directory "^[^.].*\\.eca?$" nil t t)
                      default-directory)
                    (file-name-as-directory
                     (expand-file-name
                      (read-directory-name (format-prompt "EasyCrypt source (root) directory" "") nil nil t))))))
     (list root nil)))
  (ece--exec-compile-internal root t options))

;; Subcommand: docgen
(defun ece--exec-docgen-internal (srcs &optional outdir subdirs sync)
  "Executes `easycrypt docgen' using `ece--execute-subcommand' (passing
SYNC directly), which see, generating documentation file(s) for the
EasyCrypt file SRCS or, if SRCS is a directory, EasyCrypt files in SRCS.
In the latter case, sub-directories are considered is SUBDIRS is
non-nil. The generated files are stored in OUTDIR; if SUBDIRS is
non-nil, documentation files generated for source files found in
sub-directories are stored in identically named sub-directories relative
to OUTDIR. Both SRCS and OUTDIR can be absolute or relative. Relative
paths are with respect to `default-directory', which is also the default
value for the output directory (if OUTDIR is nil)."
  (let ((esrc (expand-file-name srcs))
        (eodr (if outdir
                  (file-name-as-directory (expand-file-name outdir))
                default-directory)))
    (unless (file-readable-p esrc)
      (user-error "`%s' non-existent or not readable" srcs))
    (cond
     ((file-regular-p esrc)
      (progn
        (when (not (string-match-p "^[^.].*\\.eca?$" (file-name-nondirectory esrc)))
          (user-error "`%s' (resolved as %s) not recognized as an EasyCrypt source file: extension should be `.ec' or `.eca'"
                      srcs esrc))
        (ece--exec-execute "docgen" (concat esrc " -outdir " eodr) sync)))
     ((and (file-directory-p esrc) (not subdirs))
      (let ((srcl (directory-files esrc t "^[^.].*\\.eca?$")))
        (when (null srcl)
          (user-error "No EasyCrypt source files found in `%s' (resolved as `%s')" srcs esrc))
        (if (file-exists-p eodr)
            (when (not (and (file-directory-p eodr) (file-writable-p eodr)))
              (user-error "`%s' exists but not a writable directory" outdir))
          (make-directory eodr t))
        (dolist (src srcl) (ece--exec-execute "docgen" (concat src " -outdir " eodr) sync))))
     ((and (file-directory-p esrc) subdirs)
      (let ((srcl (directory-files-recursively esrc "^[^.].*\\.eca?$" nil t t)))
        (when (null srcl)
          (user-error "No EasyCrypt source files found in `%s' (resolved as `%s')" srcs esrc))
        (if (file-exists-p eodr)
            (when (not (and (file-directory-p eodr) (file-writable-p eodr)))
              (user-error "`%s' exists but not a writable directory" outdir))
          (make-directory eodr t))
        (dolist (src srcl)
          (let* ((pardir (file-name-parent-directory src))
                 (reldir (file-relative-name pardir esrc))
                 (eodrc (file-name-as-directory (expand-file-name reldir eodr))))
            (unless (file-directory-p eodrc)
              (make-directory eodrc t))
            (ece--exec-execute "docgen" (concat src " -outdir " eodrc) sync)))))
     (t
      (user-error "`%s' not a regular file nor a directory" srcs)))))

;;;###autoload
(defun ece-exec-docgen (srcs &optional outdir subdirs)
  "Executes `easycrypt compile' asynchronously, generating documentation
file(s) for the EasyCrypt file SRCS or, if SRCS is a directory,
EasyCrypt files in SRCS. In the latter case, sub-directories are
considered is SUBDIRS is non-nil. The generated files are stored in
OUTDIR; if SUBDIRS is non-nil, documentation files generated for source
files found in sub-directories are stored in identically named
sub-directories relative to OUTDIR. Both SRCS and OUTDIR can be absolute
or relative. Relative paths are with respect to `default-directory',
which is also the default value for the output directory (if OUTDIR is
nil or the empty string)."
  (interactive
   (let* ((projcr (project-current))
          (defdir (or (when projcr (file-name-as-directory (expand-file-name (project-root projcr))))
                      default-directory))
          (srcs (read-file-name (format-prompt "EasyCrypt source file or directory" defdir)
                                defdir defdir t))
          (projsr (project-current nil (file-name-directory srcs)))
          (srcd (or (when projsr (file-name-as-directory (expand-file-name (project-root projsr))))
                    (file-name-directory srcs)))
          (srcr (file-name-directory (file-relative-name srcs srcd)))
          (defout (expand-file-name (or srcr "") (expand-file-name ece-exec-docgen-default-outdir srcd)))
          (outdir (file-name-as-directory
                   (expand-file-name
                    (read-directory-name (format-prompt "Output directory" defout)
                                         srcd defout nil))))
          (subdirs (when (file-directory-p srcs) (yes-or-no-p "Include sub-directories?"))))
     (list srcs outdir subdirs)))
  (ece--exec-docgen-internal srcs outdir subdirs))

;;;###autoload
(defun ece-exec-docgen-file (file &optional outdir)
  "Executes `easycrypt compile' asynchronously, generating documentation
file(s) for the EasyCrypt file FILE. The generated files are stored in
OUTDIR. Both FILE and OUTDIR can be absolute or relative. Relative paths
are with respect to `default-directory', which is also the default value
for the output directory (if OUTDIR is nil or the empty string).
Interactively, FILE defaults to the file visited by the current buffer
or, if the current buffer is not visiting such a file, asks to specify a
file instead."
  (interactive
   (let* ((projcr (project-current))
          (defdir (or (when projcr (file-name-as-directory (expand-file-name (project-root projcr))))
                      default-directory))
          (buffn (buffer-file-name))
          (file (if (and buffn (string-match-p "^[^.].*\\.eca?$" (file-name-nondirectory buffn)))
                     buffn
                   (read-file-name (format-prompt "EasyCrypt source file" "")
                                   defdir nil t nil (apply-partially #'string-match-p "^[^.].*\\.eca?$"))))
          (projfl (project-current nil (file-name-directory file)))
          (filed (or (when projfl (file-name-as-directory (expand-file-name (project-root projfl))))
                     (file-name-directory file)))
          (filer (file-name-directory (file-relative-name file filed)))
          (defout (expand-file-name (or filer "") (expand-file-name ece-exec-docgen-default-outdir filed)))
          (outdir (file-name-as-directory
                   (expand-file-name
                    (read-directory-name (format-prompt "Output directory" defout)
                                         filed defout nil)))))
     (list file outdir)))
  (ece--exec-docgen-internal file outdir))

;;;###autoload
(defun ece-exec-docgen-projdir (root &optional outdir)
  "Executes `easycrypt docgen' command asynchronously, generating
documentation file(s) for the EasyCrypt files in ROOT, including
sub-directories. The generated files are stored in OUTDIR, where
documentation files generated for source files found in sub-directories
are stored in identically named sub-directories relative to OUTDIR.
Interactively, without a prefix argument, ROOT defaults to the root of
the current project or, if no project is found, asks to provide such a
root. With a prefix argument, ROOT instead defaults to
`default-directory' or, if that does not contain any EasyCrypt source
files, asks to provide a root directory instead."
  (interactive
   (let* ((projcr (when (null current-prefix-arg) (project-current t)))
          (root (or (when projcr
                      (file-name-as-directory (expand-file-name (project-root projcr))))
                    (when (directory-files-recursively default-directory "^[^.].*\\.eca?$" nil t t)
                      default-directory)
                    (file-name-as-directory
                     (expand-file-name
                      (read-directory-name (format-prompt "EasyCrypt source (root) directory" "") nil nil t)))))
          (rootp (project-current nil root))
          (rootd (or (when rootp (file-name-as-directory (expand-file-name (project-root rootp))))
                     root))
          (rootr (file-relative-name root rootd))
          (defout (expand-file-name rootr (expand-file-name ece-exec-docgen-default-outdir rootd)))
          (outdir (file-name-as-directory
                   (expand-file-name
                    (read-directory-name (format-prompt "Output directory" defout)
                                         rootd defout nil)))))
     (list root outdir)))
  (ece--exec-docgen-internal root outdir t))

;; Option: --help
(defun ece--exec-help-internal (&optional sync)
  "Executes `easycrypt --help' using `ece--exec-execute', which see,
passing SYNC directly."
  (ece--exec-execute "--help" sync))

;;;###autoload
(defun ece-exec-help ()
  "Executes `easycrypt --help' asynchronously."
  (interactive)
  (ece--exec-help-internal))

(defalias 'ece-exec---help #'ece-exec-help "Alias for `ece-exec-help', which see")

;; Subcommand: runtest
(defun ece--exec-runtest-internal (testfile scenario &optional jobs report options workdir sync)
  "Executes `easycrypt runtest' using `ece--exec-execute' (passing
SYNC directly), which see, performing the test SCENARIO specified in
TESTFILE using JOBS concurrent processes, writing a final report to
REPORT. TESTFILE can be absolute or relative. A relative path (for
TESTFILE) is interpreted with respect to `default-directory'. OPTIONS,
if non-nil, should be a string and is concatenated to the command as is.
WORKDIR, if non-nil, should be a string that specifies the working
directory for the command (this is relevant because relative paths in
the test file are interpreted with respect to the working directory)."
  (unless (or (null options) (stringp options))
    (error "ece--exec-compile-internal: OPTIONS (%s) should be nil or a string" options))
  (let ((etf (expand-file-name testfile))
        (ewd (when workdir (expand-file-name workdir))))
    (when (not (and (file-regular-p etf) (file-readable-p etf)))
      (user-error "Test configuration file `%s' (resolved as `%s') non-existent or not readable" testfile etf))
    (when (and ewd (not (and (file-directory-p ewd) (file-readable-p ewd))))
      (user-error "Working directory `%s' (resolved as `%s') non-existent or not readable" workdir ewd))
    (unless (or (null report) (string-empty-p report))
      (let ((repd (file-name-directory (expand-file-name report))))
        (if (file-exists-p repd)
            (when (not (and (file-directory-p repd) (file-writable-p repd)))
              (user-error "`%s' exists but not a writable directory" repd))
          (make-directory repd t))))
    ;; Set process-connection-type to nil to get a pipe instead of a pty
    ;; (current EasyCrypt runtest errors out with the latter)
    (let ((process-connection-type nil)
          (default-directory (or ewd default-directory))) ; default-directory determines working directory
      (ece--exec-execute "runtest"
                         (concat etf
                                 " "
                                 (if (or (null scenario) (string-empty-p scenario))
                                     ece-exec-runtest-default-scenario
                                   scenario)
                                 (when (and (integerp jobs) (< 0 jobs))
                                   (concat " -jobs " (number-to-string jobs)))
                                 (unless (or (null report) (string-empty-p report))
                                   (concat " -report " (expand-file-name report)))
                                 options)
                         sync))))

;;;###autoload
(defun ece-exec-runtest (testfile scenario &optional jobs report options workdir)
  "Executes `easycrypt runtest' asynchronously, performing the test SCENARIO
specified in TESTFILE using JOBS concurrent processes, writing a final report to
REPORT. TESTFILE can be absolute or relative. A relative path (for TESTFILE) is
interpreted with respect to `default-directory'. OPTIONS, if non-nil, should be
a string and is concatenated to the command as is. WORKDIR, if non-nil, should
be a string that specifies the working directory for the command (this is
relevant because relative paths in the test file are interpreted with respect to
the working directory)."
  (interactive
   (let* ((projcr (project-current))
          (defdir (or (when projcr (file-name-as-directory (expand-file-name (project-root projcr))))
                      default-directory))
          (deftf (expand-file-name ece-exec-runtest-default-test-file defdir))
          (defrp (expand-file-name ece-exec-runtest-default-report-file defdir))
          (testfile (read-file-name (format-prompt "Test configuration file" deftf) defdir deftf t))
          (scenario (read-string (format-prompt "Test scenario name" ece-exec-runtest-default-scenario)
                                 nil nil ece-exec-runtest-default-scenario))
          (jobs (read-number "Number of jobs, 0 to let EasyCrypt decide: " 0))
          (report (read-file-name (format-prompt "Test report file, empty for no report" defrp) defdir defrp))
          (options (read-string (format-prompt "Further options" "")))
          (testdir (file-name-directory testfile))
          (workdir (read-directory-name (format-prompt "Working directory" testdir)
                                        testdir testdir t)))
     (list testfile scenario jobs report (when (not (string-empty-p options)) options) workdir)))
  (ece--exec-runtest-internal testfile scenario jobs report options workdir))

;;;###autoload
(defun ece-exec-runtest-dflt (&optional arg)
  "Executes `easycrypt runtest' asynchronously. By default,
without a prefix argument, performs test `ece-exec-runtest-default-scenario'
specified in `ece-exec-runtest-default-test-file', writing a final report
to `ece-exec-runtest-default-report-file'. With a single prefix argument,
asks to provide a scenario; with two prefix arguments, also asks
to provide a test file; with three prefix arguments, also asks
to provide a report file; with four prefix arguments, also asks
for a working directory."
  (interactive "p")
  (let* ((projcr (project-current))
         (defdir (or (when projcr (file-name-as-directory (expand-file-name (project-root projcr))))
                     default-directory))
         (deftf (expand-file-name ece-exec-runtest-default-test-file defdir))
         (defrp (expand-file-name ece-exec-runtest-default-report-file defdir))
         (testfile (if (<= 16 arg)
                       (read-file-name (format-prompt "Test configuration file" deftf) defdir deftf t)
                     deftf))
         (scenario (if (<= 4 arg)
                       (read-string (format-prompt "Test scenario name" ece-exec-runtest-default-scenario)
                                    nil nil ece-exec-runtest-default-scenario)
                     ece-exec-runtest-default-scenario))
         (report (if (<= 64 arg)
                     (read-file-name (format-prompt "Test report file, empty for no report" defrp) defdir defrp)
                   defrp))
         (testdir (file-name-directory testfile))
         (workdir (if (<= 256 arg)
                      (read-directory-name (format-prompt "Working directory" testdir)
                                           testdir testdir t)
                    testdir)))
    (ece--exec-runtest-internal testfile scenario 0 report nil workdir)))

;; Subcommand: why3config
(defun ece--exec-why3config-internal (&optional why3file sync)
  "Executes `easycrypt why3config' using `ece--exec-execute'
(passing SYNC directly), which see, using WHY3FILE for the `-why3' option
if its non-nil (and non-empty)."
  (if (or (null why3file) (string-empty-p why3file))
      (ece--exec-execute "why3config" sync)
    (ece--exec-execute "why3config" (concat "-why3 " (expand-file-name why3file)) sync)))

;;;###autoload
(defun ece-exec-why3config (&optional why3file)
  "Executes `easycrypt why3config' asynchronously, using WHY3FILE for the
`-why3' option if its non-nil (and non-empty)."
  (interactive
   (let ((why3file (read-file-name (format-prompt "Configuration file" "determined by EasyCrypt") "~/" "")))
     (list (when (not (string-empty-p why3file)) why3file))))
  (ece--exec-why3config-internal why3file))

;;;###autoload
(defun ece-exec-why3config-dflt ()
  "Executes `easycrypt why3config' command asynchronously with default
settings."
  (interactive)
  (ece--exec-why3config-internal))

;;;###autoload
(defun ece-exec (subcommand)
  "Entry point for executing any of the supported (executable) subcommands,
as defined in `ece--exec-supported-subcommands'. Provides completion
for the possible candidates, and directly dispatches the
command corresponding to the choice upon confirmation."
  (interactive (list
                (completing-read (format-prompt "Subcommand" ece--exec-supported-subcommands)
                                 ece--exec-supported-subcommands nil t nil nil
                                 ece--exec-supported-subcommands)))
  (call-interactively (intern-soft (format "ece-exec-%s" subcommand))))


;;; Templates
(defun ece--tempel-placeholder-form-as-lit (elt)
"Defines slight adjustment of regular placeholder element
so that a prompt form evaluating to a string is inserted as
default value in the same way as a literal string prompt."
  (pcase elt
    (`(pfl ,prompt . ,rest)
     (let ((evprompt (eval prompt)))
       (if (stringp evprompt)
           `(p ,evprompt ,@rest)
         `('p ,prompt ,@rest))))))

(defun ece--tempel-include (elt)
  "Defines `include' element (taken and slightly adjusted from TempEL github repo)
that allows to include other templates by their name."
  (when (eq (car-safe elt) 'i)
    (when-let (template (alist-get (cadr elt) (tempel--templates)))
      (cons 'l template))))

(defun ece--tempel-template-file-read (file)
  (let ((res '()))
    (dolist (metatemps (tempel--file-read file))
      (let ((modes (car metatemps))
            (plist (cadr metatemps))
            (temps (cddr metatemps)))
        (when (tempel--condition-p modes plist)
          (setq res (append res temps)))))
    res))

(defsubst ece--templates-file-read ()
  (ece--tempel-template-file-read ece--templates-file))

(defsubst ece--templates-info-file-read ()
  (ece--tempel-template-file-read ece--templates-info-file))

;;;###autoload
(defmacro ece-tempel-key (keymap key template-name)
  "Binds KEY to (a function inserting) TEMPLATE-NAME in KEYMAP.
Simplified version of `tempel-key' macro from `tempel' package, but
with functionality checks."
  `(define-key ,keymap ,(key-parse key)
               ,(let ((cmd (intern (format "tempel-insert-%s" template-name))))
                  `(prog1 ',cmd
                     (defun ,cmd ()
                       ,(format "Insert template %s in the current buffer."
                                template-name)
                       (interactive)
                       (unless ece-templates
                         (user-error "Templates not enabled (i.e., `ece-templates' is nil). Try again after enabling"))
                       (ece--check-functionality 'tempel-insert 'tempel)
                       (tempel-insert ',template-name))))))


;;; Configuration
;; Indentation
(defvar-local original-indentation-state nil)

(defun ece--set-indentation-settings-local ()
  (if original-indentation-state
      (setq-local tab-width 2
                  indent-line-function #'ece-indent-line
                  electric-indent-mode nil)
    (setq-local original-indentation-state
                (buffer-local-set-state tab-width 2
                                        indent-line-function #'ece-indent-line
                                        electric-indent-mode nil)))
  (add-hook 'post-self-insert-hook #'ece-indent-closer-on-insertion-newline t))

(defun ece--reset-indentation-settings-local ()
  (when original-indentation-state
      (buffer-local-restore-state original-indentation-state)
      (setq-local original-indentation-state nil))
  (remove-hook 'post-self-insert-hook #'ece-indent-closer-on-insertion-newline t))

(defun ece--configure-indentation-settings-local (enable)
  (if enable (ece--set-indentation-settings-local) (ece--reset-indentation-settings-local)))

(defun ece--enable-indentation ()
  (ece--ece-configure-global-from-local #'ece--set-indentation-settings-local)
  (keymap-set easycrypt-ext-mode-map "RET" #'newline-and-indent)
  (keymap-set easycrypt-ext-mode-map "<return>" "RET")
  (keymap-set easycrypt-ext-mode-map "S-<return>" #'newline)
  (keymap-set easycrypt-ext-mode-map "TAB" #'ece-basic-indent)
  (keymap-set easycrypt-ext-mode-map "<tab>" "TAB")
  (keymap-set easycrypt-ext-mode-map "<backtab>" #'ece-basic-deindent)
  (keymap-set easycrypt-ext-mode-map "M-i" #'indent-for-tab-command)
  (keymap-set easycrypt-ext-mode-map "M-I" #'ece-indent-for-tab-command-inverse-style))

(defun ece--disable-indentation ()
  (keymap-unset easycrypt-ext-mode-map "RET")
  (keymap-unset easycrypt-ext-mode-map "<return>")
  (keymap-unset easycrypt-ext-mode-map "S-<return>")
  (keymap-unset easycrypt-ext-mode-map "TAB")
  (keymap-unset easycrypt-ext-mode-map "<tab>" "TAB")
  (keymap-unset easycrypt-ext-mode-map "<backtab>")
  (keymap-unset easycrypt-ext-mode-map "M-i")
  (keymap-unset easycrypt-ext-mode-map "M-I")
  (ece--ece-configure-global-from-local #'ece--reset-indentation-settings-local))

(defsubst ece--configure-indentation (enable)
  (if enable (ece--enable-indentation) (ece--disable-indentation)))

;; Keyword completion
(defun ece--enable-keyword-completion-local ()
  (unless (and (local-variable-p ece-keyword-completion) ece-keyword-completion)
    (add-to-list 'cape-keyword-list (cons 'easycrypt-mode ece-keywords))
    (setq-local ece-keyword-completion t)))

(defun ece--disable-keyword-completion-local ()
  (unless (and (local-variable-p ece-keyword-completion) (not ece-keyword-completion))
    (setq-local ece-keyword-completion nil)
    (setq-local cape-keyword-list (assq-delete-all 'easycrypt-mode cape-keyword-list))
    (when (eq cape-keyword-list (default-value 'cape-keyword-list))
      (kill-local-variable 'cape-keyword-list))))

(defsubst ece--configure-keyword-completion-local (enable)
  (ece--check-feature 'cape-keyword)
  (if enable (ece--enable-keyword-completion-local) (ece--disable-keyword-completion-local)))

(defsubst ece--configure-keyword-completion (enable)
  (ece--check-feature 'cape-keyword)
  (ece--ece-configure-global-from-local
   (if enable #'ece--enable-keyword-completion-local #'ece--disable-keyword-completion-local)))

;; Templates
(defvar-keymap ece-template-map
  :doc "Keymap for EasyCrypt templates."
  :prefix 'ece-template-map-prefix)

(dolist (keytemp ece-templates-bound)
  (let ((key (car keytemp))
        (temp (cadr keytemp)))
    (eval `(ece-tempel-key ece-template-map ,key ,temp))))

(defun ece--enable-templates-local ()
  (unless (and (local-variable-p ece-templates) ece-templates)
    (add-to-list 'tempel-user-elements #'ece--tempel-placeholder-form-as-lit)
    (add-to-list 'tempel-user-elements #'ece--tempel-include)
    (add-to-list 'tempel-template-sources #'ece--templates-file-read)
    (when tempel-abbrev-mode
      (tempel-abbrev-mode 1))
    (setq-local ece-templates t)))

(defun ece--disable-templates-local ()
  (unless (and (local-variable-p ece-templates) (not ece-templates))
    (setq-local ece-templates nil)
    (setq-local tempel-user-elements
                (remq #'ece--tempel-placeholder-form-as-lit
                      (remq #'ece--tempel-include tempel-user-elements)))
    (when (eq tempel-user-elements (default-value 'tempel-user-elements))
      (kill-local-variable 'tempel-user-elements))
    (setq-local tempel-template-sources
                (remq #'ece--templates-file-read tempel-template-sources))
    (when (eq tempel-template-sources (default-value 'tempel-template-sources))
      (kill-local-variable 'tempel-template-sources))
    (when tempel-abbrev-mode
      (tempel-abbrev-mode 1))))

(defsubst ece--configure-templates-local (enable)
  (ece--check-feature 'tempel)
  (if enable (ece--enable-templates-local) (ece--disable-templates-local)))

(defsubst ece--configure-templates (enable)
  (ece--check-feature 'tempel)
  (ece--ece-configure-global-from-local
   (if enable #'ece--enable-templates-local #'ece--disable-templates-local)))

(defun ece--enable-templates-info-local ()
  (unless (and (local-variable-p ece-templates-info) ece-templates-info)
    (add-to-list 'tempel-template-sources #'ece--templates-info-file-read)
    (when tempel-abbrev-mode
      (tempel-abbrev-mode 1))
    (setq-local ece-templates-info t)))

(defun ece--disable-templates-info-local ()
  (unless (and (local-variable-p ece-templates-info) (not ece-templates-info))
    (setq-local ece-templates-info nil)
    (setq-local tempel-template-sources
                (remq #'ece--templates-info-file-read tempel-template-sources))
    (when tempel-abbrev-mode
      (tempel-abbrev-mode 1))))

(defsubst ece--configure-templates-info-local (enable)
  (ece--check-feature 'tempel)
  (if enable (ece--enable-templates-info-local) (ece--disable-templates-info-local)))

(defsubst ece--configure-templates-info (enable)
  (ece--check-feature 'tempel)
  (ece--ece-configure-global-from-local
   (if enable #'ece--enable-templates-info-local #'ece--disable-templates-info-local)))


;;; Toggles
;;;###autoload
(defun ece-toggle-indentation-style-local ()
  "Toggles EasyCrypt Ext indentation style in this buffer."
  (interactive)
  (setq-local ece-indentation-style (if (eq ece-indentation-style 'local) 'nonlocal 'local))
  (message "EasyCrypt Ext indentation style set to %s in this buffer!"
           (if (eq ece-indentation-style 'local) "local" "non-local")))

;;;###autoload
(defun ece-toggle-keyword-completion-local ()
  "Toggles EasyCrypt Ext keyword completion in this buffer."
  (interactive)
  (ece--configure-keyword-completion-local (not ece-keyword-completion))
  (message "EasyCrypt Ext keyword completion %s in this buffer!"
           (if ece-keyword-completion "enabled" "disabled")))

;;;###autoload
(defun ece-toggle-templates-local ()
  "Toggles EasyCrypt Ext templates in this buffer."
  (interactive)
  (ece--configure-templates-local (not ece-templates))
  (message "EasyCrypt Ext templates %s in this buffer!"
           (if ece-templates "enabled" "disabled")))

;;;###autoload
(defun ece-toggle-templates-info-local ()
  "Toggles EasyCrypt Ext informative templates in this buffer."
  (interactive)
  (ece--configure-templates-info-local (not ece-templates-info))
  (message "EasyCrypt Ext informative templates %s in this buffer!"
           (if ece-templates-info "enabled" "disabled")))

;;;###autoload
(defun ece-reset-to-defaults-local ()
  "Resets relevant EasyCrypt Ext functionalities/settings in this buffer
to their global defaults."
  (interactive)
  (ece--configure-indentation-settings-local (default-value 'ece-indentation))
  (ece--configure-keyword-completion-local (default-value 'ece-keyword-completion))
  (ece--configure-templates-local (default-value 'ece-templates))
  (ece--configure-templates-info-local (default-value 'ece-templates-info))
  (message "EasyCrypt Ext options reset to their default values in this buffer!"))

;;;###autoload
(defun ece-enable-indentation ()
  "Enables EasyCrypt Ext indentation in all EasyCrypt buffers."
  (interactive)
  (ece--configure-indentation t)
  (message "EasyCrypt Ext indentation enabled in all buffers! Current style: %s." ece-indentation-style))

;;;###autoload
(defun ece-disable-indentation ()
  "Disables EasyCrypt Ext indentation in all EasyCrypt buffers."
  (interactive)
  (ece--configure-indentation nil)
  (message "EasyCrypt Ext indentation disabled in all buffers!"))

;;;###autoload
(defun ece-enable-keyword-completion ()
  "Enables EasyCrypt Ext keyword completion in all EasyCrypt buffers."
  (interactive)
  (ece--configure-keyword-completion t)
  (message "EasyCrypt Ext keyword completion enabled in all (EasyCrypt Ext) buffers!"))

;;;###autoload
(defun ece-disable-keyword-completion ()
  "Disables EasyCrypt Ext keyword completion in all EasyCrypt buffers."
  (interactive)
  (ece--configure-keyword-completion nil)
  (message "EasyCrypt Ext keyword completion disabled in all (EasyCrypt Ext) buffers!"))

;;;###autoload
(defun ece-enable-templates ()
  "Enables EasyCrypt Ext templates in all EasyCrypt buffers."
  (interactive)
  (ece--configure-templates t)
  (message "EasyCrypt Ext templates enabled in all (EasyCrypt Ext) buffers!"))

;;;###autoload
(defun ece-disable-templates ()
  "Disables EasyCrypt Ext templates in all EasyCrypt buffers."
  (interactive)
  (ece--configure-templates nil)
  (message "EasyCrypt Ext templates disabled in all (EasyCrypt Ext) buffers!"))

;;;###autoload
(defun ece-enable-templates-info ()
  "Enables EasyCrypt Ext informative templates in all EasyCrypt buffers."
  (interactive)
  (ece--configure-templates-info t)
  (message "EasyCrypt Ext informative templates enabled in all (EasyCrypt Ext) buffers!"))

;;;###autoload
(defun ece-disable-templates-info ()
  "Disables EasyCrypt Ext informative templates in all EasyCrypt buffers."
  (interactive)
  (ece--configure-templates-info nil)
  (message "EasyCrypt Ext informative templates disabled in all (EasyCrypt Ext) buffers!"))

;;;###autoload
(defun ece-reset-to-defaults ()
  "Resets all EasyCrypt Ext settings/functionalities to their
global defaults in all EasyCrypt buffers."
  (interactive)
  (ece--configure-indentation (default-value 'ece-indentation))
  (ece--configure-keyword-completion (default-value 'ece-keyword-completion))
  (ece--configure-templates (default-value 'ece-templates))
  (ece--configure-templates-info (default-value 'ece-templates-info))
  (message "EasyCrypt Ext options reset to their default values in all (EasyCrypt Ext) buffers!"))


;;; Keymaps
;; Executable (subcommands)
(defvar-keymap ece-exec-map
  :doc "Keymap for executing EasyCrypt (command line) subcommands."
  :prefix 'ece-exec-map-prefix
  "c" #'ece-exec-compile-file
  "C" #'ece-exec-compile-projdir
  "C-c" #'ece-exec-compile
  "d" #'ece-exec-docgen-file
  "D" #'ece-exec-docgen-projdir
  "C-d" #'ece-exec-docgen
  "h" #'ece-exec-help
  "r" #'ece-exec-runtest-dflt
  "R" #'ece-exec-runtest
  "w" #'ece-exec-why3config-dflt
  "W" #'ece-exec-why3config)

;; Options (enabling/disabling)
(defvar-keymap ece-options-map
  :doc "Keymap for managing options for `easycrypt-ext-mode'"
  :prefix 'ece-options-map-prefix
  "i" #'ece-enable-indentation
  "I" #'ece-disable-indentation
  "C-i" #'ece-toggle-indentation-style-local
  "k" #'ece-enable-keyword-completion
  "K" #'ece-disable-keyword-completion
  "C-k" #'ece-toggle-keyword-completion-local
  "t" #'ece-enable-templates
  "T" #'ece-disable-templates
  "C-t" #'ece-toggle-templates-local
  "o" #'ece-enable-templates-info
  "O" #'ece-disable-templates-info
  "C-o" #'ece-toggle-templates-info-local
  "r" #'ece-reset-to-defaults-local
  "R" #'ece-reset-to-defaults)

;; Modes
(defvar-keymap easycrypt-ext-general-map
  :doc "General map containing commands shared by all keymaps
of EasyCrypt Ext modes. Meant to be used as `parent' keymap for
mode-specific maps."
  "C-c C-y e" 'ece-exec-map-prefix
  "C-c C-y p" #'ece-proofshell-print
  "C-c C-y P" #'ece-proofshell-prompt-print
  "C-c C-y l" #'ece-proofshell-locate
  "C-c C-y L" #'ece-proofshell-prompt-locate
  "C-c C-y m" #'ece-proofshell-prompt-pragma
  "C-c C-y s" #'ece-proofshell-search
  "C-c C-y S" #'ece-proofshell-prompt-search
  "C-c C-y x" #'ece-exec
  "C-c C-y z" #'ece-proofshell-prompt
  "C-S-<mouse-1>" #'ece-proofshell-print
  "C-S-<mouse-2>" #'ece-proofshell-locate
  "C-S-<mouse-3>" #'ece-proofshell-search)

(defvar-keymap easycrypt-ext-mode-map
  :doc "Keymap for `easycrypt-ext-mode'."
  :parent easycrypt-ext-general-map
  "C-c C-y o" 'ece-options-map-prefix
  "C-c C-y t" 'ece-template-map-prefix)

(defvar-keymap easycrypt-ext-goals-mode-map
  :doc "Keymap for `easycrypt-ext-goals-mode'."
  :parent easycrypt-ext-general-map
  "C-S-<wheel-down>" #'ece-bufhist-prev
  "C-S-<wheel-up>" #'ece-bufhist-next)

(defvar-keymap easycrypt-ext-response-mode-map
  :doc "Keymap for `easycrypt-ext-response-mode'."
  :parent easycrypt-ext-general-map
  "C-S-<wheel-down>" #'ece-bufhist-prev
  "C-S-<wheel-up>" #'ece-bufhist-next)

;; Repeat
(defvar-keymap ece-proof-mode-process-repeat-map
  :doc "Keymap (repeatable) for processing proof commands."
  :repeat (:hints ((proof-undo-last-successful-command . "p/u: Undo last successful command")
                   (proof-assert-next-command-interactive . "n: Assert next command")
                   (proof-undo-and-delete-last-successful-command . "d: Undo and delete last successful command")))
  "u" #'proof-undo-last-successful-command
  "p" #'proof-undo-last-successful-command
  "n" #'proof-assert-next-command-interactive
  "d" #'proof-undo-and-delete-last-successful-command)

(defvar-keymap ece-bufhist-repeat-map
  :doc "Keymap (repeatable) for browsing and managing buffer history."
  :repeat (:hints ((bufhist-prev . "p: Go to previous history element")
                   (bufhist-next . "n: Go to next history element")
                   (bufhist-first . "f: Go to first history element")
                   (bufhist-last . "l: Go to last history element")
                   (bufhist-delete . "d: Delete current history element")))
  "p" #'bufhist-prev
  "n" #'bufhist-next
  "f" #'bufhist-first
  "l" #'bufhist-last
  "d" #'bufhist-delete)


;;; Menus
;; Generation (macro)
(defmacro ece--easy-menu-gen (symb map shell exec options &optional submode)
  `(easy-menu-define ,symb ,map
     ,@(let* ((mmd (concat "EasyCrypt Ext" (if (stringp submode) (format " (%s)" submode) "")))
              (mms (format "easycrypt-ext%s-mode" (if (stringp submode) (concat "-" submode) "")))
              (mmc (intern mms))
              (hmd (concat "Disable " mmd)))
         (append
          `(,(concat "Menu bar and mode line menu (clickable) for " mms))
          `('(,mmd
              :visible t
              :active t
              :help ,(concat "Menu exposing functionality provided by " mmd)
              ,@(append
                 (when shell
                   (list
                    ["Locate" ece-proofshell-locate
                     :help "Locate the item at cursor in the current EasyCrypt context."]
                    ["Locate (prompt)" ece-proofshell-prompt-locate
                     :help "Locate an item of choice in the current EasyCrypt context."]
                    ["Print" ece-proofshell-print
                     :help "Print the item at cursor from the current EasyCrypt context."]
                    ["Print (prompt)" ece-proofshell-prompt-print
                     :help "Print an item of choice from the current EasyCrypt context."]
                    ["Search" ece-proofshell-search
                     :help "Search for known axioms/lemmas from the current EasyCrypt context containing the item at cursor."]
                    ["Search (prompt)" ece-proofshell-prompt-search
                     :help "Search for known axioms/lemmas from the current EasyCrypt context containing items of choice."]
                    (when (or exec options) "-----")))
                 (when exec
                   (list
                    '("Executable (\"command line\") commands"
                      :visible t
                      :active t
                      ["Compile file" ece-exec-compile-file
                       :help "Check current EasyCrypt file."]
                      ["Compile directory/project" ece-exec-compile-projdir
                       :help "Check EasyCrypt files in current directory and its sub-directories."]
                      ["Compile (prompt)" ece-exec-compile
                       :help "Check EasyCrypt file(s) of choice."]
                      "-----"
                      ["Generate documentation file" ece-exec-docgen-file
                       :help "Generate documentation for current EasyCrypt file."]
                      ["Generate documentation directory/project" ece-exec-docgen-projdir
                       :help "Generate documentation for EasyCrypt files in current directory and its sub-directories."]
                      ["Generate documentation" ece-exec-docgen
                       :help "Generate documentation for EasyCrypt file(s) of choice."]
                      "-----"
                      ["Print help (from executable)" ece-exec-help
                       :help "Print help information as provided by the EasyCrypt executable (through \"--help\")."]
                      "-----"
                      ["Run test scenario (default)" ece-exec-runtest-dflt
                       :help "Run default test scenario (for current EasyCrypt file)."]
                      ["Run test scenario (prompt)" ece-exec-runtest
                       :help "Run test scenario of choice."])))
                 (when options
                   (list
                    '("Configuration/Options"
                      :visible t
                      :active t
                      ["Toggle enhanced indentation (local)" ece-toggle-indentation-local
                       :help "Toggle enhanced indentation in this buffer."
                       :style toggle
                       :selected ece-indentation]
                      ["Enable enhanced indentation (global)" ece-enable-indentation
                       :help "Enable enhanced indentation in all EasyCrypt Ext buffers."]
                      ["Disable enhanced indentation (global)" ece-disable-indentation
                       :help "Disable enhanced indentation in all EasyCrypt Ext buffers."]
                      "-----"
                      ["Toggle keyword completion (local)" ece-toggle-keyword-completion-local
                       :help "Toggle keyword completion in this buffer."
                       :style toggle
                       :selected ece-keyword-completion]
                      ["Enable keyword completion (global)" ece-enable-keyword-completion
                       :help "Enable keyword completion in all EasyCrypt Ext buffers."]
                      ["Disable keyword completion (global)" ece-disable-keyword-completion
                       :help "Disable keyword completion in all EasyCrypt Ext buffers."]
                      "-----"
                      ["Toggle templates (local)" ece-toggle-templates-local
                       :help "Toggle templates in this buffer."
                       :style toggle
                       :selected ece-templates]
                      ["Enable templates (global)" ece-enable-templates
                       :help "Enable templates in all EasyCrypt Ext buffers."]
                      ["Disable templates (global)" ece-disable-templates
                       :help "Disable templates in all EasyCrypt Ext buffers."]
                      "-----"
                      ["Toggle informative templates (local)" ece-toggle-templates-info-local
                       :help "Toggle informative templates in this buffer."
                       :style toggle
                       :selected ece-templates-info]
                      ["Enable informative templates (global)" ece-enable-templates-info
                       :help "Enable informative templates in all EasyCrypt Ext buffers."]
                      ["Disable informative templates (global)" ece-disable-templates-info
                       :help "Disable informative templates in all EasyCrypt Ext buffers."]
                      "-----"
                      ["Reset settings (local)" ece-reset-to-defaults-local
                       :help "Reset EasyCrypt Ext settings to their defaults in this buffer."]
                      ["Reset settings (global)" ece-reset-to-defaults
                       :help "Reset EasyCrypt Ext settings to their defaults in all EasyCrypt Ext buffers."])))
                 (append
                  (when (or shell options exec) '("-----"))
                  (list `["Disable" (,mmc -1) :help ,hmd])))))))))

(ece--easy-menu-gen easycrypt-ext-mode-menu easycrypt-ext-mode-map t t t)
(ece--easy-menu-gen easycrypt-ext-goals-mode-menu easycrypt-ext-goals-mode-map t t nil "goals")
(ece--easy-menu-gen easycrypt-ext-response-mode-menu easycrypt-ext-response-mode-map t t nil "response")


;;; Fundamental
(defvar-local original-syntax-table nil)

(defun ece--patch-syntax-table ()
  "Patches syntax table to better reflect syntactical meaning of
characters. Particularly, the following changes are applied:
- , is classified as punctuation instead of whitespace."
  (unless original-syntax-table
    (setq-local original-syntax-table (copy-syntax-table))
    (modify-syntax-entry ?, ".")))

(defun ece--restore-syntax-table ()
  "Restores original syntax table, undoing the patch performed by
`ece--patch-syntax-table', which see."
  (when original-syntax-table
    (set-syntax-table original-syntax-table)))

;;; Miscellaneous
(defun ece--recenter-goals-window ()
  "Recenters window showing goals buffer.

- If the goal is a program-logic one, center around the middle between (the
start of) the precondition and (the start of) the post-condition.
- Else, center around the line that separates goal's context from its
conclusion.

Meant for `proof-shell-handle-delayed-output-hook'."
  (when-let* ((proof-goals-window (get-buffer-window proof-goals-buffer t)))
    (with-selected-window proof-goals-window
      (goto-char (point-min))
      (re-search-forward "^-+$" nil t)
      (when-let* ((pre (re-search-forward "^pre =" nil t))
                  (post (re-search-forward "^post =" nil t)))
        (goto-char (/ (+ pre post) 2)))
      (goto-char (pos-bol))
      (set-window-point (selected-window) (point))
      (recenter-top-bottom))))


;;; Session setup/teardown
;;;###autoload
(defun ece-setup ()
  "Sets up EasyCrypt extensions."
  (ece--patch-syntax-table)

  (ece--configure-indentation ece-indentation)

  (let ((cpcnf nil)
        (tpcnf nil))
    (when ece-keyword-completion
      (with-eval-after-load 'cape-keyword
        (ece--configure-keyword-completion-local ece-keyword-completion))
      (setq cpcnf (not (featurep 'cape-keyword))))

    (when (or ece-templates ece-templates-info)
      (with-eval-after-load 'tempel
        (ece--configure-templates-local ece-templates)
        (ece--configure-templates-info-local ece-templates-info))
      (setq tpcnf (not (featurep 'tempel))))

    (when (or cpcnf tpcnf)
      (message "Attempted to setup %s not detected. Loading dependencies at any point will complete the corresponding setup automatically."
               (cond
                ((and cpcnf tpcnf)
                 "keyword completion and templates, but dependencies `cape-keyword' and `tempel' were")
                (cpcnf
                 "keyword completion, but dependency `cape-keyword' was")
                (t
                 "templates, but dependency `tempel' was"))))))

;;;###autoload
(defun ece-teardown ()
  "Tears down EasyCrypt extensions."
  (ece--restore-syntax-table)

  (if (ece--check-other-buffers-mode 'easycrypt-ext-mode)
      (ece--reset-indentation-settings-local)
    (ece--disable-indentation))

  (when (local-variable-p ece-keyword-completion)
    (ece--disable-keyword-completion-local)
    (kill-local-variable ece-keyword-completion))

  (when (local-variable-p ece-templates)
    (ece--disable-templates-local)
    (kill-local-variable ece-templates))

  (when (local-variable-p ece-templates-info)
    (ece--disable-templates-info-local)
    (kill-local-variable ece-templates-info)))

;;;###autoload
(defun ece-goals-setup ()
  "Sets up EasyCrypt extensions (goals)."
  (add-hook 'proof-shell-handle-delayed-output-hook #'ece--recenter-goals-window 90))

;;;###autoload
(defun ece-goals-teardown ()
  "Tears down EasyCrypt extensions (goals)."
  (unless (ece--check-other-buffers-mode 'easycrypt-ext-goals-mode)
    (remove-hook 'proof-shell-handle-delayed-output-hook #'ece--recenter-goals-window)))

;;; Minor modes
;; Regular
(define-minor-mode easycrypt-ext-mode nil
  :lighter " ECE"
  :keymap easycrypt-ext-mode-map
  :interactive (easycrypt-mode)
  (if easycrypt-ext-mode
      (ece-setup)
    (ece-teardown)))

;; Goals
(define-minor-mode easycrypt-ext-goals-mode nil
  :lighter " ECEg"
  :keymap easycrypt-ext-goals-mode-map
  :interactive (easycrypt-goals-mode)
  (if easycrypt-ext-goals-mode
      (ece-goals-setup)
    (ece-goals-teardown)))

;; Response
(define-minor-mode easycrypt-ext-response-mode nil
  :lighter " ECEr"
  :keymap easycrypt-ext-response-mode-map
  :interactive (easycrypt-response-mode))


(provide 'easycrypt-ext)

;;; easycrypt-ext.el ends here
