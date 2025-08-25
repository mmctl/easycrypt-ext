# EasyCrypt Extensions for Emacs (Proof-General)

-----

# THIS IS WIP. DONT USE.

[EasyCrypt](https://www.easycrypt.info/) is a toolset primarily designed for the
formal verification of code-based, game-playing crytpographic proofs. At its
core, it features an interactive theorem prover with a front-end implemented in
[Proof General](https://proofgeneral.github.io/).

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
  This tries to minimize the need for scrolling each time you process
  a command, especially when dealing with larger goals.
- Menu bar and mode line menu for managing and using (selected features of)
  EasyCrypt Ext.

Further, more advanced features are provided through integration with
other packages. Each of these is provided in a separate file/feature
called `easycrypt-ext-X`, where `X` is the name of the other package.
Specifically, these features are the following.
- Keyword completion (requires [Cape](https://github.com/minad/cape),
  specifically `cape-keyword`; see `easycrypt-ext-cape.el`).
- Code templates *with documentation* (requires [Tempel](https://github.com/minad/tempel);
  see `easycrypt-ext-tempel.el`).
- Execution of proof shell commands from a distance (requires
  [Avy](https://github.com/abo-abo/avy); see `easycrypt-ext-avy.el`).

> :exclamation: **Compatibility** :exclamation:  
> The current version of this package should be compatible with (at least)
> Emacs 29.1 or newer. However, it has only been tested with Emacs version 30.1.

# Installation and Configuration

-----

> :speech_balloon: **Target audience** :speech_balloon:  
> Since many EasyCrypt users only pick up Emacs for EasyCrypt, these
> instructions assume no prior Emacs knowledge and are written to be
> beginner-friendly. If you are an experienced Emacs user, you may prefer
> skipping most of the explanatory text and jumping straight to the code
> snippets.

The setup is presented in layers. You can stop at any stage or continue stacking
more features:[^1]

[^1]: Technically, the _Enhancements_ "layer" is independent of the others but included here because it greatly improves the overall experience.


1. [Prerequisites](#prerequisites): Set up your environment and Proof General for EasyCrypt.
2. [Basics](#basics): Set up core features of this package (no external packages).
3. [Extras](#extras): Set up extra features of this package (integration with external packages).
4. [Enhancements](#enhancements): Improve Emacs features that this package relies
   on; these also benefit your general Emacs usage.

Each step includes ready-to-use code snippets with comments explaining what
they do. Customization is optional, but the snippets also suggest common tweaks
if you’d like to go beyond the defaults.

When you’re done here, check out [Tips and Tricks](#tips-and-tricks)
for additional quality-of-life improvements.

> :eyes: **Finding your initialization file** :eyes:   
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

## Prerequisites

> :eyes: **Skipping prerequisites** :eyes:  
> Even if you already set up MELPA and Proof General, skimming these
> instructions may still be useful for learning about recommended defaults and
> configuration options that integrate better with this package.

1. **Add [MELPA](https://melpa.org/#/getting-started) as a package archive**  
   Add the following snippet to your initialization file, which will
   add MELPA to the considered package archives and initialize the
   package system the next time Emacs launches.

   > :exclamation: **No need to repeat** :exclamation:  
   > If you already have `(require 'package)` and `(package-initialize)`
   > statement in your initialization file, you do _not_ need to add
   > them again. In that case, just add the second line from the snippet 
   > (putting it after `(require 'package)`).

   ```emacs-lisp
   (require 'package)
   (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
   (package-initialize)
   ```

2. **Set up [Proof General](https://proofgeneral.github.io/download/)**  
   Add the following snippet to your initialization file, which will install and
   configure Proof General the next time Emacs launches. All settings appear
   under `:init` and are set to the recommended defaults. However, each one is
   optional: you can remove, keep, or adjust them as you like.

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

      > :eyes: **Changing settings** :eyes:  
      > In the above, you can enable (resp. disable) a setting by assigning `t`
      > (resp. `nil`). (For `setopt`, the first argument is the variable and the
      > second argument is the assigned value.)

3. **Restart Emacs**  
   Restart Emacs for the changes to take effect. If Emacs launches without errors, you should be good to go.

## Basics

1. **Set up EasyCrypt Ext (this package)**  
    Add the following snippet to your initialization file, which will
    install EasyCrypt Ext the next time Emacs launches. All settings appear
    under `:config` and are set to the recommended defaults. However, each one is
    optional: you can remove, keep, or adjust them as you like.

    ```emacs-lisp
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
        ;; Enable repeat maps to quickly repeat certain commands after issuing them once.
        ;; This is a global setting and will apply to all buffers in the current Emacs session.
        (repeat-mode 1))
    ```

    > :eyes: **Further customization** :eyes:  
    > EasyCrypt Ext provides several customization options for more advanced use
    > cases (e.g., enabling or disabling specific features, or executing EasyCrypt
    > command-line commands from inside Emacs). You can view the documentation for a
    > customization variable with `C-h v` (Control + h, then v), then typing the
    > variable name and pressing enter. Searching for the prefix `ece-` should bring
    > up all the available variables. You can set these variables with `setopt`
    > inside an `:init` block of the `use-package easycrypt-ext` statement. For an
    > example of such an `:init` block , see the the Proof General configuration in
    > [Prerequisites](#prerequisites).

2. **Restart Emacs**  
   Restart Emacs for the changes to take effect. If Emacs starts without errors, you should be good to go.

That’s it! EasyCrypt Ext now loads automatically with EasyCrypt (e.g., when you
open an `.ec` or `.eca` file). To get familiar with the available features,
commands, and keybindings, see the relevant parts of [Features, Commands,
and Keybindings](#features-commands-and-keybindings). Alternatively, check out
[Extras](#extras), [Enhancements](#enhancements), or [Tips and
Tricks](#tips-and-tricks) to unlock additional features and further improve your
experience!

## Extras

1. **Set up external packages**  
   Add the following snippet to your initialization file, which will install and
   configure [Cape](https://github.com/minad/cape),
   [Tempel](https://github.com/minad/tempel), and
   [Avy](https://github.com/abo-abo/avy) the next time Emacs launches. If you
   don't want a certain package, simply remove its `use-package` block. Although
   these packages are rather customizable, the defaults should be fine for most
   use cases, so we keep the configuration minimal here. For possible
   customization, see the package repositories (linked in the comments) or [Tips
   and Tricks](#tips-and-tricks).

    ```emacs-lisp
    ;; Cape (keyword completion)
    ;; https://github.com/minad/cape
    (use-package cape
        :ensure t)

    ;; Tempel (code templates)
    ;; https://github.com/minad/tempel
    (use-package tempel
        :ensure t

        :bind
        ;; Bind template completion to "M-+"
        ;; (change this to whatever keybinding you prefer)
        ("M-+" . tempel-complete)

    ;; Avy (jumping and acting from a distance)
    ;; https://github.com/abo-abo/avy
    (use-package avy
        :ensure t
        :pin melpa)
    ```

2. **Set up EasyCrypt Ext integration with external packages.**  
   Add the following snippet to your initialization file, which will configure
   EasyCrypt Ext's integration with the external packages the next time Emacs
   launches. If you don't want to use a certain package integration, simply
   remove its `use-package` block. All settings appear under `:init` and
   `:config` and are set to some basic, non-conflicting defaults.

   ```emacs-lisp
    (use-package easycrypt-ext-cape
        :ensure nil ; Comes with EasyCrypt Ext

        :hook
        (easycrypt-ext-mode . easycrypt-ext-mode-cape-setup)

        :config
        ;; Add (resp. remove) `cape-keyword' to (resp. from) the functions
        ;; used for completion whenever EasyCrypt Ext loads (resp. unloads)
        (defun setup-ece-cape-keyword ()
            (if easycrypt-ext-mode
                (add-hook 'completion-at-point-functions #'cape-keyword nil t)
              (remove-hook 'completion-at-point-functions #'cape-keyword t)))
        (add-hook 'easycrypt-ext-mode-hook #'setup-ece-cape-keyword))

    (use-package easycrypt-ext-tempel
        :ensure nil ; Comes with EasyCrypt Ext

        :hook
        (easycrypt-ext-mode . easycrypt-ext-mode-tempel-setup)

        :init
        ;; Set keybinding to accesss predefined template map to "C-c C-y t",
        ;; (change this to whatever keybinding you prefer)
        (setopt ece-tempel-template-map-prefix "C-c C-y t"))

    (use-package easycrypt-ext-avy
        :ensure nil ; Comes with EasyCrypt Ext

        :hook
        (easycrypt-ext-mode . easycrypt-ext-mode-avy-setup)
        (easycrypt-ext-goals-mode . easycrypt-ext-goals-mode-avy-setup)
        (easycrypt-ext-response-mode . easycrypt-ext-response-mode-avy-setup))
   ```

3. **Restart Emacs**  
   Restart Emacs for the changes to take effect. If Emacs starts without errors, you should be good to go.

And you're done! The extra integration features now load automatically alongside
EasyCrypt Ext and should work out of the box. Usage and customization of the
available features are detailed in [Features, Commands, and
Keybindings](#features-commands-and-keybindings). For further improvement of
your experience, check out [Enhancements](#enhancements) or [Tips and
Tricks](#tips-and-tricks)!

## Enhancements

Some features of this package—especially the integrations with Cape and
Tempel—make heavy use of Emacs’s completion system (both in-buffer and
minibuffer). The built-in completion works fine if you’re comfortable with it,
but you may prefer a smoother and more user-friendly experience. For that, we
recommend two lightweight external packages: Corfu (for an in-buffer completion
pop-up) and Vertico (for a minibuffer completion interface). [^2]

[^2]: Both are by the same author as Cape and Tempel, giving great interoperability.

> :exclamation: **Global settings ahead** :exclamation:  
> The settings in this section apply globally across Emacs, not just when
> EasyCrypt Ext is active. For most users this will be an improvement, but if
> you already have specific preferences or other configurations, be mindful of
> possible conflicts. In any case, reverting is as simple as removing the added
> code.

1. **Set up Corfu and Vertico**  
   Add the following snippet to your initialization file, which will install and
   activate Corfu and Vertico the next time Emacs launches. If you don't want to
   use a certain package, simply remove its `use-package` block. Both packages
   are highly customizable, but their defaults are good enough for most use
   cases. For possible customization, see the package repositories (linked in
   the comments) [Tips and Tricks](#tips-and-tricks).

   > :eyes: **Activation, not configuration** :eyes  
   > In this case, the settings under `:config` only activate the packages: They
   > are not optional defaults (as in earlier sections), but rather setup to
   > enable the packages at all.

    ```emacs-lisp
    ;; Corfu (in-buffer completion pop-up/interface)
    ;; https://github.com/minad/corfu
    (use-package corfu
        :ensure t

        :config
        (global-corfu-mode 1))

    ;; Vertico (minibuffer completion interface)
    ;; https://github.com/minad/vertico
    (use-package vertico
        :ensure t

        :config
        (vertico-mode 1))
   ```

2. **Restart Emacs**  
   Restart Emacs to ensure necessary operations are performed
   and changes take effect. If Emacs starts without errors, you
   should be good to go.

And that's it! Corfu and Vertico should now be up-and-running from launch.
To test them right away, try the following:
- Open your initialization file with `find-file`, bound by default to `C-x C-f`
  (Control + x, then Control + f). As you type the filename, you should see a
  dynamic list of completion candidates you can browse and select. That’s
  Vertico at work.
- Once inside your initialization file, type `use` and trigger completion with
  `completion-at-point`, bound by default to `C-M-i` (Control + Meta + i).[^4]
  You should see a popup of completion suggestions that updates as you
  type. That's Corfu in action.

[^4]: Typically, `Meta` is `Alt` (or `Command` on Mac).

For a full overview of EasyCrypt Ext's features and how to use them, see
[Features, Commands, and Keybindings](#features-commands-and-keybindings). For
additional quality-of-life tweaks and refinements, check out [Tips and
Tricks](#tips-and-tricks).

# Features, Commands, and Keybindings

-----

Below are the most relevant available commands and their default keybindings.
Some commands can also be accessed through the corresponding menus in the menu
bar and mode line.

> :eyes: **Default keybindings and changing them** :eyes:  
> To avoid conflicts with other keybindings (from Proof General or otherwise),
> nearly all keybindings for this package begin with the prefix `C-c C-y`.
> Depending on your personal keybindings and how many Proof General keybindings
> you want to use, there may be (a lot) more convenient alternatives.

## Indentation

## Proof Shell

| Command             | Keybinding                      | Description                     |
|---------------------|---------------------------------|---------------------------------|
| `ece-locate`        | `C-c C-y l` and `C-S-<mouse 2>` | `locate` item at point or click |
| `ece-print`         | `C-c C-y p` and `C-S-<mouse 1>` | `print` item at point or click  |
| `ece-search`        | `C-c C-y p` and `C-S-<mouse 3>` | `search` item at point or click |
| `ece-prompt-locate` | `C-c C-y L` and `C-c -`         | Prompt for item to `locate`     |
| `ece-prompt-print`  | `C-c C-y P` and `C-c =`         | Prompt for item to `print`      |
| `ece-prompt-search` | `C-c C-y S` and `C-c /`         | Prompt for item to `search`     |

## Executable (Command Line)

| Command               | Keybinding      | Description                                                                           |
|-----------------------|-----------------|---------------------------------------------------------------------------------------|
| `ece-compile-file`    | `C-c C-y e c`   | `compile` (check) visited EasyCrypt file                                              |
| `ece-compile-dir`     | `C-c C-y e C`   | `compile` (check) EasyCrypt files in visited directory and its children               |
| `ece-compile`         | `C-c C-y e C-c` | Prompt for EasyCrypt file(s) to `compile` (check)                                     |
| `ece-docgen-file`     | `C-c C-y e d`   | `docgen` (generate documentation) visited EasyCrypt file                              |
| `ece-docgen-dir`      | `C-c C-y e D`   | `docgen` generate documentation EasyCrypt files in visited directory and its children |
| `ece-docgen`          | `C-c C-y e C-d` | Prompt for EasyCrypt file(s) to `docgen` (generate documentation)                     |
| `ece-help`            | `C-c C-y e h`   | Print help (as output by `easycrypt --help`)                                          |
| `ece-runtest-dflt`    | `C-c C-y e r`   | `runtest` (test) using default test file and scenario (relative to visited directory) |
| `ece-runtest`         | `C-c C-y e R`   | Prompt for configuration to use with `runtest` (test)                                 |
| `ece-why3config-dflt` | `C-c C-y e w`   | `why3config` (configure Why3) using default configuration file                        |
| `ece-why3config`      | `C-c C-y e W`   | Prompt for configuration file to use with `why3config` (configure Why3).              |

## Templates
Built-in template map.

## Miscellaneous
- Imenu
- Auto centering and echoing of remaining goals
- 

# Tips and Tricks

## Corfu automatic (including templates)
## Cape dabbrev
## Consult Imenu
## Behavior of Shift-TAB
## Silencing bufhist buttons
