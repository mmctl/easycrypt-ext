;;; easycrypt-ext-tempel.el --- Tempel Integration for EasyCrypt Extensions -*- lexical-binding: t; -*-
(require 'easycrypt-ext)
(require 'tempel)


;;; Customization
(defgroup easycrypt-ext-tempel nil
  "Customization group for EasyCrypt Ext integration with `tempel'."
  :prefix "ece-tempel"
  :group 'easycrypt-ext)

(defcustom ece-tempel-template-map-entries
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


;;; Documentation
;; (defun ece-tempel--print-documentation (elts)
;;   "Print documentation of template ELTS."
;;   (while (and elts (not (keywordp (car elts))))
;;     (pop elts))
;;   (plist-get elts :doc))

;; (defun ece-tempel--insert-doc-buffer-content (elts)
;;   "Insert documentation buffer content for template ELTS."
;;   (insert (concat (propertize "Preview" 'face '(:underline t)) "\n"))
;;   (insert (tempel--print-template elts))
;;   (when-let* ((doc (tempel--print-documentation elts)))
;;     (insert (concat "\n\n" (propertize "Documentation" 'face '(:underline t)) "\n"))
;;     (insert doc)))

;; (defun ece-tempel--complete (tc &rest args)
;;   "Replaces `:company-doc-buffer' property of TC (which should be
;; `tempel-complete') such that, in addition to a template preview, the
;; documentation string (i.e., the string associated with the `:doc' keyword) of
;; the template is printed. Heavily inspired by
;; `cape-wrap-properties' from the `cape' package (see:
;; https://github.com/minad/cape).

;; Meant as advice `:around' `tempel-complete'."
;;   (if easycrypt-ext-mode
;;       (pcase (apply tc args)
;;         (`(,beg ,end ,templates . ,plist)
;;          `(,beg ,end ,templates
;;                 ,@(plist-put
;;                    plist
;;                    :company-doc-buffer
;;                    (apply-partially #'tempel--info-buffer
;;                                     templates
;;                                     #'(lambda (elts)
;;                                         (ece-tempel--insert-doc-buffer-content elts)
;;                                         (current-buffer)))))))
;;     (apply tc args)))

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
  ;; (advice-add 'tempel-complete :around #'ece-tempel--complete)
  (when tempel-abbrev-mode
    (tempel-abbrev-mode 1))
  (keymap-set easycrypt-ext-mode-map ece-tempel-template-map-prefix 'ece-template-map-prefix))

(defun ece-tempel--disable-templates ()
  (keymap-unset easycrypt-ext-mode-map ece-tempel-template-map-prefix)
  ;; (advice-remove 'tempel-complete #'ece-tempel--complete)
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
