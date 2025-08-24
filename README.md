# EasyCrypt Extensions for Emacs (Proof-General)

-----

# THIS IS WIP. DONT USE.

[EasyCrypt](https://www.easycrypt.info/) is a toolset primarily designed for the
formal verification of code-based, game-playing crytpographic proofs. At its
core, it features an interactive theorem prover with a front-end implemented in
[Proof General](https://proofgeneral.github.io/)

This package aims to add useful extensions to this EasyCrypt front-end.
Basic/standalone features include the following.
- Improved (but still ad-hoc) indentation.
- Imenu integration; i.e., proper indexing of items (like
  axioms, lemmas, types, operators, theorems) to allow for
  quick navigation through Imenu.
- Repeat (key)maps for quickly repeating certain commands
  after issuing them once. Currently implemented for processing,
  undoing, and deleting proof commands, as well as browsing
  through goal/response history (if enabled through Proof General).
- Execution of proof shell commands through keybindings or mouse clicks
  (eliminating the need to manually type the corresponding commands).
  Supported commands are `print`, `search`, and `locate`.
- Interactive setting of pragmas, with completion for most of them.
  Allows for, e.g., quickly enabling/disabling weak-check mode
  to process parts of the proof script faster.
- Execution of command line (sub)commands from Emacs through keybindings.
  Supported commands are `compile`, `docgen`, `runtest`, `why3config`,
  and `--help` (which is actually an option, but you get the point).
  Where relevant, this functionality is extended to the directory/project
  level, enabling you to execute a (sub)commands for each EasyCrypt
  file in a project or directory (tree).
- Automatic "smart" centering of goal buffer and echoing of remaining goals.
  This tries to minimize the need for scrolling each time you processing
  a command when dealing with larger goals.
- Menu bar and mode line menu for managing and using (selected features of)
  EasyCrypt Ext.

Further, more advanced features are provided through integration with
other packages. Each of these is provided in a separate file/feature
called `easycrypt-ext-X`, where `X` is the name of the other package.
Specifically, these features are the following.
- Keyword completion (requires [cape](https://github.com/minad/cape),
  specifically cape-keyword; see `easycrypt-ext-cape`).
- Code templates (requires  [tempel](https://github.com/minad/tempel);
  see `easycrypt-ext-tempel`).
- Execution of proof shell commands from a distance (requires
  [avy](https://github.com/abo-abo/avy); see `easycrypt-ext-avy`).

> :exclamation:
> The current version of this package should be compatible with (at least)
> Emacs 29.1 or newer. However, it has only been tested with Emacs version 30.1.

## Installation and Configuration

> :speech_balloon:
> Since many EasyCrypt users only pick up Emacs for EasyCrypt, these
> instructions assume no prior Emacs knowledge and are written to be
> beginner-friendly. If you are an experienced Emacs user, you may prefer
> skipping most of the explanatory text and jumping straight to the code
> snippets.

The setup is presented in layers. You can stop at any stage or continue stacking
more features:[^1]

[^1]: Technically, the _Enhancements_ "layer" is independent of the others but included here because it greatly improves the overall experience.


1. [Prerequisites](#prerequisites) -- Set up your environment and Proof General for EasyCrypt.
2. [Basics](#basics) -- Set up core features of this package (no external packages).
3. [Extra](#extra) -- Set up extra features of this package (integration with external packages).
4. [Enhancements](#enhancements) -- Improve Emacs features that this package relies
   on; these also benefit your general Emacs usage.

Each layer comes with ready-to-use code snippets you can copy into your
configuration. Customization is optional, but the snippets also provide
explanations and suggestions for common tweaks if you’d like to go beyond the
defaults.

When you’re done here, don’t miss the Tips and Tricks section for further
quality-of-life improvements.

> :eyes:
> Most of the instructions below involve editing your
> [Emacs initialization file](https://www.gnu.org/software/emacs/manual/html_node/emacs/Init-File.html). 
> This file can live in different places, most commonly:
> - `~/emacs.d/init.el`
> - `~/.emacs`
> - `~/.config/emacs/init.el`
> To check which one your Emacs uses:
> 1. Open Emacs.
> 2. Press `C-h v` (Control + h, then v).
> 3. Type `user-init-file` and hit enter.
> Emacs will display something like:
> ```
> Its value is "/home/you/.emacs.d/init.el"
> ```

### Prerequisites

> :eyes:
> Even if you already set up MELPA and Proof General, skimming these
> instructions may still be useful for learning about recommended defaults and
> configuration options that integrate better with this package.

1. **Add [MELPA](https://melpa.org/#/getting-started) as a package archive**
   Add the following snippet to your initialization file.
       ```emacs-lisp
   (require 'package)
   (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
   (package-initialize)
   ```

2. **Install and configure Proof General**
Add the following snippet to your initialization file. The settings under
`:init` are recommended defaults. However,
everything is optional: you can remove, keep, or adjust them as you like your
liking.

      ```emacs-lisp
     ;; Proof General
     ;; Front-end framework for proof assistants, used by EasyCrypt.
     ;; See: https://github.com/ProofGeneral/PG (and https://proofgeneral.github.io/)
     (use-package proof-general
       :ensure t ; Install if not already available
       :pin melpa ; Get the up-to-date version from Melpa

       :init
       ;; Disable splash screen
       (setopt proof-splash-enable nil)

       ;; Keep a browsable goal/response history without undoing steps
       (setopt proof-keep-response-history t)

       ;; Disable automatic indentation in EasyCrypt proof scripts.
       (setopt easycrypt-script-indent nil)

       ;; Disable formatting for newlines after each command.
       (setopt easycrypt-one-command-per-line nil))
       ```

    > :eyes:
    > You can enable (resp. disable) a setting by assigning `t` (resp. `nil).
    > (For `setopt`, the second argument is the assigned value.x)

3. **Restart Emacs**
   Restart Emacs to ensure necessary operations are performed
   and changes take effect. If Emacs starts without errors, you’re good to go.

### Basics

### Extra
To set up this package, simply add the following to your initialization file.
#+begin_src elisp
  ;; Install EasyCrypt Ext if not already available
  (unless (package-installed-p 'easycrypt-ext)
    (package-vc-install "https://github.com/mmctl/easycrypt-ext" nil 'Git
                        'easycrypt-ext))


  ;; EasyCrypt Extensions
  ;; Extensions for EasyCrypt in Emacs
  ;; See: https://github.com/mmctl/easycrypt-ext
  (use-package easycrypt-ext
    :ensure nil ; Already installed above

    :hook
    (easycrypt-mode . easycrypt-ext-mode)
    (easycrypt-goals-mode . easycrypt-ext-goals-mode)
    (easycrypt-response-mode . easycrypt-ext-response-mode)

    :config
    ;; Enable use of repeat maps, which allow you to
    ;; repeat certain commands quickly after issuing them once.
    ;; Used by `easycrypt-ext' for processing, undoing, and deleting proof steps,
    ;; as well as browsing through goal/response history.
    ;; Note that this is a global mode, i.e., it will apply to all
    ;; buffers in the current Emacs session.
    ;; Remove if you don't want this behavior.
    (repeat-mode 1)

    ;; Advanced customization
    ;; See the documentation of the variables for more information. 
    ;; (Press `C-h v', type the name of the variable, and hit enter to
    ;; access the documentation; alternatively, look at the source code)
    ;; ece-indentation
    ;; ece-imenu
    ;; ece-exec-runtest-default-test-file
    ;; ece-exec-runtest-default-scenario
    ;; ece-exec-runtest-default-report-file
    ;; ece-exec-runtest-default-scenarios
    )
#+end_src

Restart to have Emacs process this and make sure you nothing is wrong.  
And that's it, at least for the basic functionality.
You can now enjoy EasyCrypt with better indentation, Imenu integration,
print/search/locate on click/press, "smart" centering, and more. Everything is loaded automatically with EasyCrypt, e.g., when you open a `.ec` or `.eca` file.

If you want to make use of more advanced functionality that involves
other packages, e.g., keyword completion or code templates, continue
reading.

** Cape (Keyword Completion)
#+begin_src elisp
  ;; Cape (completion-at-point functionality)
  ;; See: https://github.com/minad/cape
  (use-package cape
    :ensure t)
#+end_src

#+begin_src elisp
(use-package easycrypt-ext-cape
  :ensure nil ; Provided by `easycrypt-ext'

  :hook
  (easycrypt-ext-mode . easycrypt-ext-mode-cape-setup))
#+end_src

** Tempel (Templates)
#+begin_src elisp
    ;; Tempel (code templates)
    ;; See: https://github.com/minad/tempel
    (use-package tempel
      :ensure t

      :bind
      ;; Keybinding for initiating template completion
      ;; Can change to any desired keybinding (sequence)
      ;; by changing "M-+" to another keybinding string.
      ("M-+" . tempel-complete))
#+end_src

#+begin_src elisp
  (use-package easycrypt-ext-tempel
    :ensure nil ; Provided by `easycrypt-ext'

    :hook
    (easycrypt-ext-mode . easycrypt-ext-mode-tempel-setup)

    :init
    ;; Prefix (keybinding sequence) to access the
    ;; template map of EasyCrypt Ext for fast template insertion.
    ;; Can set to any keybinding (sequence) of your liking
    ;; by changing "C-c l t" to another keybinding (sequence) string.
    (setopt ece-tempel-template-map-prefix "C-c l t"))
#+end_src

** Avy (Jumping)
#+begin_src elisp
(use-package avy
  :ensure t

  :pin melpa)
#+end_src

#+begin_src elisp
(use-package easycrypt-ext-avy
  :ensure nil ; Provided by `easycrypt-ext'

  :hook
  (easycrypt-ext-mode . easycrypt-ext-mode-avy-setup)
  (easycrypt-ext-goals-mode . easycrypt-ext-goals-mode-avy-setup)
  (easycrypt-ext-response-mode . easycrypt-ext-response-mode-avy-setup))
#+end_src

TODO: comment about finding documentation in Emacs and file

* Commands (and Keybindings)
Below are the most relevant available commands and their default keybindings.
Some commands can also be accessed through the corresponding menus in the menu
bar and mode line.

#+begin_quote
To avoid conflicts with other keybindings (from Proof General o otherwise), all
keybindings for this package begin with the prefix `C-c C-y`. Depending on your
personal keybindings and how many Proof General keybindings you want to use,
there may be (a lot) more convenient alternatives.
#+end_quote

** Indentation

** Proof Shell

| Command             | Keybinding                      | Description                     |
|---------------------+---------------------------------+---------------------------------|
| `ece-locate`        | `C-c C-y l` and `C-S-<mouse 2>` | `locate` item at point or click |
| `ece-print`         | `C-c C-y p` and `C-S-<mouse 1>` | `print` item at point or click  |
| `ece-search`        | `C-c C-y p` and `C-S-<mouse 3>` | `search` item at point or click |
| `ece-prompt-locate` | `C-c C-y L` and `C-c -`         | Prompt for item to `locate`     |
| `ece-prompt-print`  | `C-c C-y P` and ~C-c `~         | Prompt for item to `print`      |
| `ece-prompt-search` | `C-c C-y S` and `C-c /`         | Prompt for item to `search`     |

** Executable (Command Line)

| Command               | Keybinding      | Description                                                                           |
|-----------------------+-----------------+---------------------------------------------------------------------------------------|
| `ece-compile-file`    | `C-c C-y e c`   | `compile` (check) visited EasyCrypt file                                              |
| `ece-compile-dir`     | `C-c C-y e C`   | `compile` (check) EasyCrypt files in visited directory and its children               |
| `ece-compile`         | `C-c C-y e C-c` | Prompt for EasyCrypt file(s) to `compile` (check)                                     |
| `ece-docgen-file`     | `C-c C-y e d`   | `docgen` (generate documentation) visited EasyCrypt file                              |
| `ece-docgen-dir`      | `C-c C-y e D`   | docgen ` generate documentation EasyCrypt files in visited directory and its children |
| `ece-docgen`          | `C-c C-y e C-d` | Prompt for EasyCrypt file(s) to `docgen` (generate documentation)                     |
| `ece-help`            | `C-c C-y e h`   | Print help (as output by `easycrypt --help`)                                          |
| `ece-runtest-dflt`    | `C-c C-y e r`   | `runtest` (test) using default test file and scenario (relative to visited directory) |
| `ece-runtest`         | `C-c C-y e R`   | Prompt for configuration to use with `runtest` (test)                                 |
| `ece-why3config-dflt` | `C-c C-y e w`   | `why3config` (configure Why3) using default configuration file                        |
| `ece-why3config`      | `C-c C-y e W`   | Prompt for configuration file to use with `why3config` (configure Why3).              |

** Templates
Built-in template map.

* Enhancements
** Corfu
** Vertico

* Tips and Tricks
** Consult Imenu
** Behavior of Shift-TAB
** Silencing bufhist buttons

* Footnotes
