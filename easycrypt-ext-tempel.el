(require 'easycrypt-ext)
(require 'tempel)

;; Customization
(defcustom ece-tempel-keymap-templates
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


;; Constants
(defconst ece--templates-file
  (expand-file-name "easycrypt-ext-templates.eld" ece--dir)
  "File where code templates for EasyCrypt are stored.")

;; Utils
(defun ece-tempel--template-file-read ()
  (let ((res '()))
    (dolist (metatemps (tempel--file-read ece--templates-file))
      (let ((modes (car metatemps))
            (plist (cadr metatemps))
            (temps (cddr metatemps)))
        (when (tempel--condition-p modes plist)
          (setq res (append res temps)))))
    res))

;; (defsubst ece--templates-file-read ()
;;   (ece--tempel-template-file-read ece--templates-file))

;; Keymap
(defvar-keymap ece-template-map
  :doc "Keymap for EasyCrypt templates."
  :prefix 'ece-template-map-prefix)

(dolist (keytemp ece-templates-bound)
  (let ((key (car keytemp))
        (temp (cadr keytemp)))
    (eval `(tempel-key ,key ,temp ece-template-map))))


;; Setup and teardown
(defun ece-tempel--enable-templates ()
  (add-to-list 'tempel-user-elements #'ece--tempel-include)
  (add-to-list 'tempel-template-sources #'ece--templates-file-read)
  (when tempel-abbrev-mode
    (tempel-abbrev-mode 1)))

(defun ece-tempel--disable-templates ()
  (setq tempel-user-elements (remq #'ece--tempel-include tempel-user-elements))
  (setq tempel-template-sources
        (remq #'ece--templates-file-read tempel-template-sources))
  (when tempel-abbrev-mode
    (tempel-abbrev-mode 1)))

(defun easycrypt-ext-mode-tempel-setup ()
  "Sets up (and tears down) `tempel' integration for `easycrypt-ext-mode'.

Meant for `easycrypt-ext-mode-hook'."
  (if easycrypt-ext-mode
      (ece-tempel--enable-templates)
    (ece-tempel--disable-templates)))
