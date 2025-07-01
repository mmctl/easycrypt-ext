;; -*- lexical-binding: t -*-
;; Environment
;; CHECK
(defconst ECE_DIR
  (file-name-as-directory (file-name-concat user-emacs-directory "local/easycrypt-ext/"))
  "Directory where `easycrypt-ext` package is located. By default it is the
local/easycrypt-ext/ directory, relative to your emacs configuration directory.
You can find this directory by launching Emacs, pressing `C-h v' (i.e., `Control
+ h' followed by `v'), typing `user-emacs-directory', and press Return (i.e.,
Enter). You can replace the above `(file-name-as-directory (file-name-concat ...))'
form with a string containing the absolute path to the directory as well." )

;;; Add ECE_DIR to the load path, so we can load files from it
(add-to-list 'load-path ECE_DIR)

;; Package system
;;; Load package system
(require 'package)

;;; Add MELPA package archive
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;;; Initialize package system
(package-initialize)

;;; Install `use-package' if not already installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;;; Refresh package contents if still needed
(unless package-archive-contents
  (package-refresh-contents))

;;; Ensure use-package is loaded
(require 'use-package)


;; Packages
;; Completions
;;; Cape
;;; Completion-at-point (read: completion of thing you are typing)
;;; functionality. Used by `easycrypt-ext' to provide
;;; support for keyword completion through `cape-keyword'. Additionally allows
;;; for the addition/combination of other such completion functions, and easy
;;; integration with `tempel' for template (completion) support.
;; See: https://github.com/minad/cape
(use-package cape
  :ensure t)

;;; Tempel
;;; Define and integrate templates ("code snippets") in standard
;;; workflow. Used by `easycrypt-ext' to provide template support. Can be easily
;;; integrated with (and without) `cape'.
;;; See: https://github.com/minad/tempel
(use-package tempel
  :ensure t)

;;; Corfu
;;; In-buffer completion user interface (i.e., to actually use the
;;; completion functions provided by, e.g., `cape' and `tempel') in the
;;; form of a pop-up.
;;; Not needed, but recommended if you make use of completions.
;;; See: https://github.com/minad/corfu
(use-package corfu
  :ensure t

  :init
  ;; CONSIDER
  ;; Let completion pop-up show up automatically while you type
  ;; (setopt corfu-auto t) ; make pop-up automatic
  ;; (setopt corfu-on-exact-match nil) ; don't automatically complete on single match

  :config
  ;; CONSIDER
  ;; Change completion keybindings to not use up/down arrow and return/enter
  ;; for performing actions in the pop-up. This may especially be
  ;; worthwhile if you have the pop-up show up automatically.
  ;; (keymap-unset corfu-map "RET") ; Don't use return/enter for inserting a completion candidate
  ;; (keymap-unset corfu-map "<up>") ; Don't use up arrow for going up in the pop-up
  ;; (keymap-unset corfu-map "<remap> <previous-line>") ; Don't use default "previous line command" for going up in the pop-up
  ;; (keymap-unset corfu-map "<down>") ; Don't use down arrow for going down in the pop-up
  ;; (keymap-unset corfu-map "<remap> <next-line>") ; Don't use default "next line command" for going down in the pop-up
  ;; (keymap-set corfu-map "C-p" #'corfu-previous) ; Example: Use `Control + p' for going up in the pop-up
  ;; (keymap-set corfu-map "C-n" #'corfu-next) ; Example: Use `Control + n' for going down in the pop-up
  ;; (keymap-set corfu-map "C-v" #'corfu-insert) ; Example: Use `Control + v' for inserting a completion candidate

  ;; CONSIDER
  ;; If you want to accept completions with return/enter,
  ;; the following makes this more consistent.
  ;; (keymmap-set corfu-map "<return>" "RET")
  )

;;; Vertico
;;; Minibuffer completion user interface (used whenever asked
;;; for user input).
;;; Not needed, but recommended if you use commands that require
;;; user input (of which `easycrypt-ext' also has several).
;;; See: https://github.com/minad/vertico
(use-package vertico
  :ensure t

  :config
  (vertico-mode 1))

;; Proof assistants
;;; Proof-General
;;; Generic proof assistant (front-end) framework used by EasyCrypt.
;;; See: https://github.com/ProofGeneral/PG (and https://proofgeneral.github.io/)
(use-package proof-general
  :ensure t

  :pin melpa ; Get the up-to-date version from Melpa

  :init
  ;; Settings
  ;;; General
  ;; Disable start-up screen (splash)
  ;; (Can set to `t' to enable, and can set `proof-splash-time'
  ;; to number  of seconds you want it displayed.)
  (setopt proof-splash-enable nil)
  ;; Disable "electric terminator", i.e., don't automatically
  ;; send command to proof assistant upon entering terminator (`.' in EasyCrypt)
  ;; (Can set to `t` to enable.)
  (setopt proof-electric-terminator-enable nil)
  ;; Enable "browsable" goal/response history (i.e., allow for browsing
  ;; through goal/history history without undoing proof steps).
  ;; (Can set to `nil' to disable.)
  (setopt proof-keep-response-history t)
  ;; Disable automatically collapsing proofs as they are completed and saved.
  ;; In any case, can fold/unfold completed proofs using `pg-toggle-visibility',
  ;; bound to `C-c v' by default.
  ;; (Can set to `t' to enable.)
  (setopt proof-disappearing-proofs nil)

  ;;; EasyCrypt
  ;; Disable built-in automatic indentation in EasyCrypt proof scripts.
  ;; (Can set to `t' to enable, but don't.)
  (setopt easycrypt-script-indent nil)
  ;; Disable formatting for newlines after each command.
  ;; (Can set to `t' to enable, but don't.)
  (setopt easycrypt-one-command-per-line nil))


;;; EasyCrypt Extension
;;;
(use-package easycrypt-ext
  :ensure nil ; Provided locally (make sure to set `ECE_DIR' properly)

  :hook ((easycrypt-mode . easycrypt-ext-mode)
         (easycrypt-goals-mode . easycrypt-ext-goals-mode)
         (easycrypt-response-mode . easycrypt-ext-response-mode))

  :init
  ;; Basic settings
  ;;; Enable enhanced (but still ad-hoc) indentation for EasyCrypt.
  ;;; See documentation of indentation-related functions in `easycrypt-ext.el'
  ;;; for details on the behavior (a good starting point is `ece--indent-level').
  ;;; (Can disable by setting to `nil'.)
  (setopt ece-indentation t)
  ;;; Enable completion for EasyCrypt keywords (depends on `cape', see above).
  ;;; This essentially adds all keywords in EasyCrypt to the `cape-keyword-list' (but
  ;;; only for EasyCrypt mode, of course), after which the `cape-keyword'
  ;;; completion-at-point function will return completions for these keywords.
  ;;; However, to actually use this, you need to tell Emacs you want to use
  ;;; `cape-keyword' as a completion-at-point function. See below for examples.
  ;;; Can disable by setting to `nil'.
  (setopt ece-keyword-completion t)
  ;;; Enable templates for EasyCrypt (depends on `tempel', see above).
  ;;; This essentially loads all templates in `easycrypt-ext-templates.eld' into `tempel',
  ;;; allowing you to insert, expand, or complete templates using
  ;;; `tempel-insert', `tempel-expand', or `tempel-complete', respectively.
  ;;; You can bind these commands to keybindings, but also use `tempel-expand' and/or
  ;;; `tempel-complete' as completion-at-point functions. See below for examples.
  ;;; Can disable by setting to `nil'.
  (setopt ece-templates t)
  ;;; Enable informative templates for EasyCrypt (depends on `tempel', see above).
  ;;; Analogous to `ece-enable-templates', but for the (informative) templates defined in
  ;;; `easycrypt-ext-templates-info.eld'.
  (setopt ece-templates-info t)

  ;; Advanced settings (See documentation for details)
  ;; ece-indentation-style
  ;; ece-templates-bound
  ;; ece-runtest-default-test-files
  ;; ece-runtest-default-scenario
  ;; ece-runtest-default-report-file
  ;; ece-docgen-default-outdir

  :config
  ;; CONSIDER
  ;; Enable mode to make use of repeat maps, which allow you to
  ;; repeat certain commands quickly after issuing them once.
  ;; Used by `easycrypt-ext' for processing, undoing, and deleting proof steps,
  ;; as well as browsing through goal/response history.
  ;; Note that this is a global mode, i.e., it will apply to all
  ;; buffers in the current Emacs session.
  ;; (repeat-mode 1)

  ;; EXAMPLE: completion-at-point-functions
  ;; Add `tempel-complete' and `cape-keyword' as completion-at-point functions
  ;; considered simultaneously (rather than sequentially, which is the default)
  ;; whenever you enter `easycrypt-mode', e.g., by opening an EasyCrypt file.
  (add-hook 'easycrypt-ext-mode-hook
            #'(lambda ()
                (setq-local completion-at-point-functions
                            (cons (cape-wrap-super #'tempel-complete #'cape-keyword)
                                  completion-at-point-functions))))

  ;; CONSIDER (EXAMPLE: completion-at-point-functions)
  ;; As the previous example, but *also* add `cape-dabbrev', which provides
  ;; completion candidates for text in current buffers. This allows you to
  ;; also get completions for identifiers (of, e.g., operators, modules, etc.)
  ;; somewhere in an opened EasyCrypt file.
  ;; (add-hook 'easycrypt-ext-mode-hook
  ;;           #'(lambda ()
  ;;               (setq-local completion-at-point-functions
  ;;                           (cons (cape-capf-super #'tempel-complete #'cape-keyword #'cape-dabbrev)
  ;;                                 completion-at-point-functions
                                  ))))

  ;; CONSIDER
  ;; Enable Corfu automatically when opening an EasyCrypt file
  ;; (add-hook 'easycrypt-ext-mode-hook #'corfu-mode)

  ;; CONSIDER (EXAMPLE: keybindings)
  ;; To prevent unwanted clashes with other keybindings (by Proof General
  ;; or otherwise), all keybindings of `easycrypt-ext' are prefixed with
  ;; `C-c C-y'. However, depending on your personal keybindings and
  ;; how many of the bindings provided by Proof General you use,
  ;; there may be more convenient alternatives.
  ;; The following is an example rebinding every top-level keybinding
  ;; provided by `easycrypt-ext', including those accessing the
  ;; sub-keymaps for managing options and external executable commands.
  ;; If you also want to change the (relative) keybindings in the sub-keymaps,
  ;; use `(keymap-set <subkeymap> <binding> <command>)';
  ;; for example, (keymap-set ece-exec-map-prefix "x" #'ece-compile)
  ;; (keymap-set easycrypt-ext-mode-map "C-c C-p" #'ece-print)
  ;; (keymap-set easycrypt-ext-mode-map "C-c l p" #'ece-print)
  ;; (keymap-set easycrypt-ext-mode-map "C-c l P" #'ece-print-prompt)
  ;; (keymap-set easycrypt-ext-mode-map "C-c l l" #'ece-locate)
  ;; (keymap-set easycrypt-ext-mode-map "C-c l L" #'ece-locate-prompt)
  ;; (keymap-set easycrypt-ext-mode-map "C-c C-s" #'ece-search)
  ;; (keymap-set easycrypt-ext-mode-map "C-c l s" #'ece-search)
  ;; (keymap-set easycrypt-ext-mode-map "C-c l S" #'ece-search-prompt)
  ;; (keymap-set easycrypt-ext-mode-map "C-c l o" 'ece-options-map-prefix)
  ;; (keymap-set easycrypt-ext-mode-map "C-c C-t" 'ece-template-map-prefix)
  ;; (keymap-set easycrypt-ext-mode-map "C-c l t" 'ece-template-map-prefix)
  ;; (keymap-set easycrypt-ext-mode-map "C-c C-e" 'ece-exec-map-prefix)
  ;; (keymap-set easycrypt-ext-mode-map "C-c l e" 'ece-exec-map-prefix)

  ;; (keymap-set easycrypt-ext-goals-mode-map "C-c C-p" #'ece-print)
  ;; (keymap-set easycrypt-ext-goals-mode-map "C-c l p" #'ece-print)
  ;; (keymap-set easycrypt-ext-goals-mode-map "C-c l P" #'ece-prompt-print)
  ;; (keymap-set easycrypt-ext-goals-mode-map "C-c l l" #'ece-prompt-locate)
  ;; (keymap-set easycrypt-ext-goals-mode-map "C-c l L" #'ece-prompt-locate)
  ;; (keymap-set easycrypt-ext-goals-mode-map "C-c C-s" #'ece-search)
  ;; (keymap-set easycrypt-ext-goals-mode-map "C-c l s" #'ece-search)
  ;; (keymap-set easycrypt-ext-goals-mode-map "C-c l S" #'ece-prompt-search)
  ;; (keymap-set easycrypt-ext-goals-mode-map "C-c C-e" 'ece-exec-map-prefix)
  ;; (keymap-set easycrypt-ext-goals-mode-map "C-c l e" 'ece-exec-map-prefix)

  ;; (keymap-set easycrypt-ext-response-mode-map "C-c C-p" #'ece-print)
  ;; (keymap-set easycrypt-ext-response-mode-map "C-c l p" #'ece-print)
  ;; (keymap-set easycrypt-ext-response-mode-map "C-c l P" #'ece-print-prompt)
  ;; (keymap-set easycrypt-ext-response-mode-map "C-c l l" #'ece-locate)
  ;; (keymap-set easycrypt-ext-response-mode-map "C-c l L" #'ece-locate-prompt)
  ;; (keymap-set easycrypt-ext-response-mode-map "C-c C-s" #'ece-search)
  ;; (keymap-set easycrypt-ext-response-mode-map "C-c l s" #'ece-search)
  ;; (keymap-set easycrypt-ext-response-mode-map "C-c l S" #'ece-search-prompt)
  ;; (keymap-set easycrypt-ext-response-mode-map "C-c C-e" 'ece-exec-map-prefix)
  ;; (keymap-set easycrypt-ext-response-mode-map "C-c l e" 'ece-exec-map-prefix)
  )
