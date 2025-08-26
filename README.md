# EasyCrypt Extensions for Emacs (Proof-General)

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

## Table of Contents

-----

# Getting Started

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

Each step provides ready-to-use code snippets with explanatory comments. You can
copy and paste them as-is for a complete setup with sensible defaults; no
changes required. Of course, there’s plenty of room for customization if you’d
like.

When you’re done here, check out [Features, Commands, and
Keybindings](#features-commands-and-keybindings) for an overview and explanation
of the available features, and [Tips and Tricks](#tips-and-tricks) for further
quality-of-life improvements.

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
> 3. Type `user-init-file` and hit Enter.
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
   > If your initialization file already includes `(require 'package)` and
   > `(package-initialize)`, you don’t need to add them again. In that case,
   > simply add the second line from the snippet, placing it after `(require
   > 'package)`.

   ```emacs-lisp
   (require 'package)
   (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
   (package-initialize)
   ```

2. **Set up [Proof General](https://proofgeneral.github.io/download/)**  
   Add the following snippet to your initialization file, which will install and
   configure Proof General the next time Emacs launches. The recommended
   configuration appears under `:init`. However, every setting is optional: you
   can remove, keep, or adjust as you like.

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
   Restart Emacs for the changes to take effect. If Emacs launches without
   errors, you should be good to go.

## Basics

1. **Set up EasyCrypt Ext (this package)**  
    Add the following snippet to your initialization file, which will install
    EasyCrypt Ext the next time Emacs launches. The recommended configuration
    appears under `:config`, which activates a _global setting_ (`repeat-mode`)
    when EasyCrypt Ext loads to enable repeat maps. Although these maps are
    generally useful, you can safely remove it if you prefer not to
    alter your Emacs's behavior outside of EasyCrypt development.

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
        ;; Enable repeat maps (globally) to quickly repeat certain commands
        ;; after issuing them once.
        (repeat-mode 1))
    ```

2. **Restart Emacs**  
   Restart Emacs for the changes to take effect. If Emacs starts without errors,
   you should be good to go.

That’s it! EasyCrypt Ext should now load automatically with EasyCrypt (e.g.,
when you open an `.ec` or `.eca` file). To get familiar with the available
features, see [Features, Commands, and
Keybindings](#features-commands-and-keybindings). Alternatively, check out
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
   these packages are quite configurable, their defaults should be fine for most
   use cases. For configuration options and ideas, see the package repositories
   (linked in the comments) or [Tips and Tricks](#tips-and-tricks).

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
        :pin melpa

        :bind
        ;; Bind character jump command to "M-g j"
        ;; (change this to whatever jump command and keybinding you prefer)
        ("M-g j" . avy-goto-char))
    ```

2. **Set up EasyCrypt Ext integration with external packages.**  
   Add the following snippet to your initialization file, which will configure
   EasyCrypt Ext's integration with the external packages the next time Emacs
   launches. If you don't want to use a certain package integration, simply
   remove its `use-package` block. Basic configurations are provided under
   `:init` and `:config`, sufficient to get started. For additional tweaks and
   options, see [Tips and Tricks](#tips-and-tricks).

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
   Restart Emacs for the changes to take effect. If Emacs starts without errors,
   you should be good to go.

And you're done! The extra integration features should now load automatically
alongside EasyCrypt Ext and work out of the box. The available featuresare
further detailed in [Features, Commands, and
Keybindings](#features-commands-and-keybindings). For additional improvement of
your experience, check out [Enhancements](#enhancements) or [Tips and
Tricks](#tips-and-tricks)!

## Enhancements

Some features of this package—especially the integrations with Cape and
Tempel—make heavy use of Emacs’s completion system (both in-buffer and
minibuffer). The built-in completion works fine if you’re comfortable with it,
but you may prefer a smoother and more user-friendly experience. For that, we
recommend two lightweight external packages: Corfu (for an in-buffer completion
pop-up) and Vertico (for a minibuffer completion interface). [^2]

[^2]: Both are by the same author as Cape and Tempel, ensuring great interoperability.

> :exclamation: **Global settings ahead** :exclamation:  
> The settings in this section apply globally across Emacs at startup, not just
> when EasyCrypt Ext is active. If you already have specific preferences or
> completion-related configurations, you may want to skip this section or at
> least be aware of potential conflicts. In any case, reverting the
> suggested changes is straightforward.

1. **Set up Corfu and Vertico**  
   Add the following snippet to your initialization file, which will install and
   activate Corfu and Vertico the next time Emacs launches. If you don't want to
   use a certain package, simply remove its `use-package` block. Both packages
   are highly configurable, but their defaults are good enough for most use
   cases. For configuration options and ideas, see the package repositories
   (linked in the comments) [Tips and Tricks](#tips-and-tricks).

    ```emacs-lisp
    ;; Corfu (in-buffer completion pop-up/interface)
    ;; https://github.com/minad/corfu
    (use-package corfu
        :ensure t

        :config
        ;; Activate Corfu (globally)
        (global-corfu-mode 1))

    ;; Vertico (minibuffer completion interface)
    ;; https://github.com/minad/vertico
    (use-package vertico
        :ensure t

        :config
        ;; Activate Vertico (globally)
        (vertico-mode 1))
   ```

2. **Restart Emacs**  
   Restart Emacs for the changes to take effect. If Emacs starts without errors,
   you should be good to go.
   
Done! Corfu and Vertico should now be up-and-running from launch.
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

For an overview and explanation of EasyCrypt Ext's features, see [Features,
Commands, and Keybindings](#features-commands-and-keybindings). For additional
quality-of-life tweaks and refinements, check out [Tips and
Tricks](#tips-and-tricks).

-----

# Features, Commands, and Keybindings

The following provides an overview of the main (interactive) features of
EasyCrypt Ext and explains how to use (and potentially configure) them. It also
lists the most relevant commands and their default keybindings. Although often
not mentioned explicitly, some commands are also available through the menu bar
and mode line menus.

> :eyes: **General configuration** :eyes:  
> Most packages, including EasyCrypt Ext and the external ones mentioned here,
> expose configuration options through customization variables. If you know the
> name of a variable, you can look up its documentation by pressing `C-h v`
> (Control + h, then v), typing the variable name, and hitting Enter. You can
> set these variables with `setopt` in your initialization file. Alternatively,
> you can search and set these variables through [Emacs's customization
> interface](https://www.gnu.org/software/emacs/manual/html_node/emacs/Easy-Customization.html),

> :eyes: **Keybindings** :eyes:  
> To avoid conflicts with other keybindings (from Proof General or elsewhere),
> nearly all EasyCrypt Ext keybindings use the prefix `C-c C-y`.
>
> Depending on your personal setup and workflow, there may be (a lot) more
> convenient alternatives. You can rebind a command with `(keymap-set KEYMAP KEY
> COMMAND)` in the `:config` block of the relevant `use-package` declaration
> (typically of the package defining the command). For example, to bind the
> command `ece-print` (provided by EasyCrypt Ext) to "C-c C-p", you could add
> the following to the `use-package` declaration for `easycrypt-ext`:
> ```
> (keymap-set easycrypt-ext-general-map`"C-c C-p" #'ece-print)
> ```
> (`easycrypt-ext-general-map` is the keymap where EasyCrypt Ext binds most of
> its commands.)


## Indentation
As you would expect, indentation is mostly automatic with EasyCrypt Ext: It
provides its own implementation of the standard Emacs indentation command and
ensures it is triggered at convenient points (e.g., after closing expressions or
inserting newlines). However, because this solution is still somewhat ad-hoc,
it may not always produce the indentation you expect or want. To cover such
cases, EasyCrypt Ext also includes:

- **Basic (de)indentation**  
Commands that indent/deindent every line in the selected region by one tab, or
insert/remove a tab at point if no region is active.
- **"Non-local" indentation**  
Command that behaves identically to the default, except in specific cases.[^6]
The main difference concerns indentation inside delimited expressions: While the
default indents relative to the previous line ("locally"), this command indents
relative to the expression's opening delimiter ("non-locally"). For more
details, see the documentation of the relevant commands.

[^6]: This is in an attempt to predict common scenarios one might run into with the default indentation.

| Command                               | Keybinding      | Description                                |
|---------------------------------------|-----------------|--------------------------------------------|
| `ece-basic-indent`                    | `M-i`           | Basic indent                               |
| `ece-basid-deindent`                  | `M-I`           | Basic deindent                             |
| `ece-indent-for-tab-command-nonlocal` | `<backtab>`[^7] | "Non-local" variant of default indentation |

[^7]: `<backtab>` is a special key usually triggered by Shift + TAB.

| Customization variable | Default | Description                                                |
|------------------------|---------|------------------------------------------------------------|
| `ece-indentation`      | `t`     | Enable (`t`) or disable (`nil` EasyCrypt Ext's indentation |

## Proof Shell

The proof shell is the part of EasyCrypt that processes proof script commands,
including not only regular proof steps but also meta-commands such as
printing/searching/locating items in the current context and setting pragmas
(i.e., proof shell options). Normally, you would type these commands directly
into your proof script, process them like any other proof step, and then remove
them again (or leave them in, cluttering your script). EasyCrypt Ext streamlines
this workflow by providing dedicated commands that (1) directly
print/search/locate the highlighted item, the item at point, or an item you
click with the mouse, or (2) prompt you for the item to use print/search/locate,
or the pragma to set.

| Command             | Keybinding                      | Description                                       |
|---------------------|---------------------------------|---------------------------------------------------|
| `ece-locate`        | `C-c C-y l` and `C-S-<mouse 2>` | `locate` highlighted item, or item at point/click |
| `ece-print`         | `C-c C-y p` and `C-S-<mouse 1>` | `print` highlighted, or item at point/click       |
| `ece-search`        | `C-c C-y p` and `C-S-<mouse 3>` | `search` highlighted item, or at point/click      |
| `ece-prompt-locate` | `C-c C-y L` and `C-c -`         | Prompt for item to `locate`                       |
| `ece-prompt-print`  | `C-c C-y P` and `C-c =`         | Prompt for item to `print`                        |
| `ece-prompt-search` | `C-c C-y S` and `C-c /`         | Prompt for item to `search`                       |

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
- Built-in template map.
- Viewing documentation (with Corfu)

## Miscellaneous
- Imenu
- Auto centering and echoing of remaining goals

-----

# Tips and Tricks

## Corfu automatic (including templates)
## Cape dabbrev
## Consult Imenu
## Behavior of Shift-TAB
## Silencing bufhist buttons


> :eyes: **Configuration** :eyes:  

> [Prerequisites](#prerequisites).
