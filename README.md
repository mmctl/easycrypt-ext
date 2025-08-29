# EasyCrypt Extensions for Emacs (Proof-General)

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

- [EasyCrypt Extensions for Emacs (Proof-General)](#easycrypt-extensions-for-emacs-proof-general)
  - [Table of Contents](#table-of-contents)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Basics](#basics)
  - [Extras](#extras)
  - [Enhancements](#enhancements)
- [Features, Commands, and Keybindings](#features-commands-and-keybindings)
  - [Indentation](#indentation)
  - [Proof Shell](#proof-shell)
  - [Executable (Command Line)](#executable-command-line)
  - [Keyword Completion and Templates](#keyword-completion-and-templates)
  - [Acting From a Distance](#acting-from-a-distance)
  - [Miscellaneous](#miscellaneous)
- [Tips and Tricks](#tips-and-tricks)
  - [Automatic Completion Popup (Corfu)](#automatic-completion-popup-corfu)
  - [Documentation Popup (Corfu)](#documentation-popup-corfu)
  - [Additional Completion Functions (Cape)](#additional-completion-functions-cape)
  - [Enhanced Imenu (Consult)](#enhanced-imenu-consult)

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

> :speech_balloon: **Skipping prerequisites** :speech_balloon:  
> Even if you already set up MELPA and Proof General, skimming these
> instructions may still be useful for learning about recommended defaults and
> configuration options that integrate better with this package.

1. **Add [MELPA](https://melpa.org/#/getting-started) as a package archive**  
   Add the following snippet to your initialization file, which will
   add MELPA to the considered package archives and initialize the
   package system the next time Emacs launches.

   > :exclamation: **No need to repeat** :exclamation:  
   > If your initialization file already includes any of the following lines,
   > you don't need to add them again. Simply add the missing lines from the
   > snippet in the same relative place (i.e., first`(require 'package)`,
   > then `(add-to-list ...)`, and lastly `package-initialize`).

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
        :pin melpa ; Get the version from Melpa

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

      <details>
      <summary>Changing settings :eyes:</summary>
      In the above, you can enable (resp. disable) a setting by assigning `t`
      (resp. `nil`). (For `setopt`, the first argument is the variable and the
      second argument is the assigned value.)
      </details>

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
        ;; Ensure EasyCrypt Ext loads whenever EasyCrypt loads
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
        ;; Bind template completion and expansion to "M-+" and "M-*", respectively
        ;; (change this to whatever keybindings you prefer)
        ("M-+" . tempel-complete)
        ("M-*" . tempel-expand)

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
        ;; Ensure Cape integration loads whenever EasyCrypt Ext loads
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
        ;; Ensure Tempel integration loads whenever EasyCrypt Ext loads
        (easycrypt-ext-mode . easycrypt-ext-mode-tempel-setup)

        :init
        ;; Set keybinding to accesss predefined template map to "C-c C-y t",
        ;; (change this to whatever keybinding you prefer)
        (setopt ece-tempel-template-map-prefix "C-c C-y t"))

    (use-package easycrypt-ext-avy
        :ensure nil ; Comes with EasyCrypt Ext

        :hook
        ;; Ensure Avy integration loads whenever EasyCrypt Ext loads
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
recommend two lightweight external packages:
[Corfu](https://github.com/minad/corfu) (for an in-buffer completion pop-up) and
[Vertico](https://github.com/minad/vertico) (for a minibuffer completion
interface). [^2]

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
> set these variables with `setopt` in your initialization file, typically in
> the `:init` block of the corresponding package's `use-package` declaration.
> Alternatively, you can search and set these variables through [Emacs's
> customization
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

[^6]: This is in an attempt to predict common scenarios you might run into with the default indentation.

| Command                               | Keybinding      | Description                                |
|---------------------------------------|-----------------|--------------------------------------------|
| `ece-basic-indent`                    | `M-i`           | Basic indent                               |
| `ece-basid-deindent`                  | `M-I`           | Basic deindent                             |
| `ece-indent-for-tab-command-nonlocal` | `<backtab>`[^7] | "Non-local" variant of default indentation |

[^7]: `<backtab>` is a special key usually triggered by Shift + TAB.

## Proof Shell

The proof shell is the part of EasyCrypt that processes proof script commands,
including not only regular proof steps but also meta-commands such as
printing/searching/locating items in the current context and setting pragmas
(i.e., proof shell options). Normally, you would type these commands directly
into your proof script, process them like any other proof step, and remove them
again (or leave them in, cluttering your script). EasyCrypt Ext streamlines this
by providing dedicated commands that (1) directly print/search/locate the
highlighted item, the item at point, or the item you click with the mouse, or
(2) prompt you for the item to use print/search/locate, or the pragma to set.
When prompting for a pragma, EasyCrypt Ext provides possible completions based
on a set of known pragmas.

<p align="center">
  <img src="https://github.com/mmctl/easycrypt-ext/blob/assets/example-print-commands.gif" width="95%" alt="Demonstration of print commands">
  <br>
  <em>Printing item at point (first) and at mouse click (second).</em>
</p>

| Command                        | Keybinding                      | Description                                                 |
|--------------------------------|---------------------------------|-------------------------------------------------------------|
| `ece-proofshell-locate`        | `C-c C-y l` and `C-S-<mouse 2>` | `locate` highlighted item, or item at point/click           |
| `ece-proofshell-print`         | `C-c C-y p` and `C-S-<mouse 1>` | `print` highlighted, or item at point/click                 |
| `ece-proofshell-search`        | `C-c C-y p` and `C-S-<mouse 3>` | `search` highlighted item, or item at point/click           |
| `ece-proofshell-prompt`        | `C-c C-y z` and `C-c :`         | Prompt (with completion) for proof shell command to execute |
| `ece-proofshell-prompt-locate` | `C-c C-y L` and `C-c -`         | Prompt for item to `locate`                                 |
| `ece-proofshell-prompt-print`  | `C-c C-y P` and `C-c =`         | Prompt for item to `print`                                  |
| `ece-proofshell-prompt-search` | `C-c C-y S` and `C-c /`         | Prompt for item to `search`                                 |

## Executable (Command Line)

EasyCrypt Ext lets you run EasyCrypt's executable subcommands directly from
Emacs, so there’s no need to switch contexts. While the executable subcommands
typically operate on a single file, EasyCrypt Ext provides commands that lift
them to the project or directory level, executing them on every relevant file.
The automatic detection of the project root or relevant directory should work
well for most cases, though you can still specify files or directories manually
if needed.

| Command                    | Keybinding              | Description                                                                             |
|----------------------------|-------------------------|-----------------------------------------------------------------------------------------|
| `ece-exec`                 | `C-c C-y x` and `C-c !` | Prompt (with completion) for executable command to execute                              |
| `ece-exec-compile-file`    | `C-c C-y e c`           | `compile` (check) current EasyCrypt file                                                |
| `ece-exec-compile-projdir` | `C-c C-y e C`           | `compile` (check) EasyCrypt files in current project/directory tree                     |
| `ece-exec-compile`         | `C-c C-y e C-c`         | Prompt for EasyCrypt file(s) to `compile` (check)                                       |
| `ece-exec-docgen-file`     | `C-c C-y e d`           | `docgen` (generate documentation for) current EasyCrypt file                            |
| `ece-exec-docgen-projdir`  | `C-c C-y e D`           | `docgen` (generate documentation for) EasyCrypt files in current project/directory tree |
| `ece-exec-docgen`          | `C-c C-y e C-d`         | Prompt for EasyCrypt file(s) to `docgen` (generate documentation for)                   |
| `ece-exec-help`            | `C-c C-y e h`           | Print help (as output by `easycrypt --help`)                                            |
| `ece-exec-runtest-dflt`    | `C-c C-y e r`           | `runtest` (test) using default test file and scenario                                   |
| `ece-exec-runtest`         | `C-c C-y e R`           | Prompt for configuration to use with `runtest` (test)                                   |
| `ece-exec-why3config-dflt` | `C-c C-y e w`           | `why3config` (configure Why3) using default configuration file                          |
| `ece-exec-why3config`      | `C-c C-y e W`           | Prompt for configuration file to use with `why3config` (configure Why3)                 |

| Customization variable                 | Value            | Description                                                                                |
|----------------------------------------|------------------|--------------------------------------------------------------------------------------------|
| `ece-exec-runtest-default-test-file`   | `"tests.config"` | Default test file (relative to project root/parent directory) to use with `runtest`        |
| `ece-exec-runtest-default-scenario`    | `"default"`      | Default test scenario name to use with `runtest`                                           |
| `ece-exec-runtest-default-report-file` | `"report.log"`   | Default report file (relative to project root/parent directory) to use with `runtest`      |
| `ece-exec-docgen-default-outdir`       | `"docs/"`        | Default output directory  (relative to project root/parent directory) to use with `docgen` |

## Keyword Completion and Templates

Keyword and template completion is straightforward: you can either call the
dedicated commands directly (`cape-keyword` for keywords, `tempel-complete` for
templates), or add them to `completion-at-point-functions` and invoke
`completion-at-point` (by default bound to `C-M-i`). For templates, Tempel also
provides `tempel-expand`, which directly expands a template if there is an exact
match, but does not launch the completion interface when multiple candidates
exist (e.g., when one template name is a prefix of another). If you kept the
default configuration from [Getting Started](#getting-started), `cape-keyword`
is included in `completion-at-point-functions`, while `tempel-complete` and
`tempel-expand` are available on dedicated keybindings.

<p align="center">
  <img src="https://github.com/mmctl/easycrypt-ext/blob/assets/example-cape-keyword.gif" width="45%" alt="Demonstration of keyword completion (with Corfu)">
  <br>
  <em>Keyword completion using <code>cape-keyword</code> with Corfu</em>
</p>

Template names follow a simple convention: three letters from the first keyword,
with optional mnemonic suffixes for other keywords or variants. For example, the
template for `require import` is named `reqimp`; the template for inserting a
module is named `mod`, and its parameterized variant is named `modp` (p for
"parameterized"). Some templates fall outside this convention, such as those
without keywords or cases where several keywords share the same three-letter
prefix. In such situations, representative names are chosen on a case-by-case
basis. All templates are defined in `easycrypt-ext-templates.eld`.

<p align="center">
  <img src="https://github.com/mmctl/easycrypt-ext/blob/assets/example-tempel-complete.gif" width="45%" alt="Demonstration of tempel completion (and Corfu)">
  &nbsp; &nbsp; &nbsp; &nbsp;
  <img src="https://github.com/mmctl/easycrypt-ext/blob/assets/example-tempel-expand.gif" width="45%" alt="Demonstration of tempel expansion (and Corfu)">
  <br>
  <em>Template completion and expansion using <code>tempel-complete</code> (left) and <code>tempel-expand</code> (right) with Corfu</em>
</p>

If you use Corfu (recommended), you can configure it to show completions
automatically as you type (see [Automatic Completion Popup
(Corfu)](#automatic-completion-popup-corfu)). Corfu also lets you view template
documentation by pressing `M-h` while a template is selected in the completion
popup. By default this opens a separate window, but it can be configured to
instead show a documentation popup beside the completions (see [Documentation
Popup (Corfu)](#documentation-popup-corfu))

<p align="center">
  <img src="https://github.com/mmctl/easycrypt-ext/blob/assets/example-tempel-documentation-corfu.gif" width="95%" alt="Demonstration of template documentation (with Corfu, window)">
  <br>
  <em>Template documentation with Corfu (window)</em>
</p>

In addition, EasyCrypt Ext provides a dedicated keymap for directly inserting
specific templates. By default this keymap is available under the prefix `C-c
C-y t`, though both the prefix and the bound templates are fully configurable.

| Customization variable            | Value                         | Description                                                |
|-----------------------------------|-------------------------------|------------------------------------------------------------|
| `ece-tempel-template-map-prefix`  | `"C-c C-y t"`                 | Prefix to access EasyCrypt Ext's template map              |
| `ece-tempel-template-map-entries` | See `easycrypt-ext-tempel.el` | Alist of templates to bind in EasyCrypt Ext's template map |

## Acting From a Distance

EasyCrypt Ext integrates with Avy by adding configurable dispatch actions for
printing, searching, and locating items at a distance (optionally moving point
as well). A detailed explanation of Avy’s dispatch system is out of scope here;
see [Avy's repository](https://github.com/abo-abo/avy) for more information.

| Customization variable   | Value                      | Description                      |
|--------------------------|----------------------------|----------------------------------|
| `ece-avy-dispatch-alist` | See `easycrypt-ext-avy.el` | Alist of dispatch actions to add |


## Miscellaneous

While EasyCrypt Ext includes additional features beyond those described above,
most are non-interactive or require no change to your usual workflow. The below
lists a few of the remaining ones.

- **Imenu integration**  
  Imenu provides an index menu for quick navigation, by default bound to `M-g i`
  (Meta + g, then i). While Emacs supports this out of the box, each mode is
  responsible for defining how the menu is populated. Proof General does not
  provide a suitable definition for EasyCrypt, so EasyCrypt Ext provides one: it
  fills the menu with types, operators, constants, module types, modules,
  axioms, lemmas, and theories defined in the current file, also creating
  corresponding categories.
- **Scrolling through goals/response history**  
  If Proof General’s goal and response histories are enabled (as in the default
  setup of [Getting Started](#getting-started)), EasyCrypt Ext adds commands for
  scrolling through them with the mouse wheel. By default, `C-S-<wheel-down>`
  (command: `ece-bufhist-prev`) scrolls backward, and `C-S-<wheel-up>` (command:
  `ece-bufhist-next`) scrolls forward.
- **Automatic centering of goals and echoing number of remaining goals**  
  When a proof command is processed, Proof General redraws the goal/response
  buffer without adjusting the window position, often leaving the interesting
  parts scrolled out of view. This is especially inconvenient for goals with
  large contexts or programs, where the interesting part is usually at the end
  or middle. EasyCrypt Ext improves this by automatically centering the window
  around (what it thinks is) a relevant point depending on the goal type. Since
  this can hide the number of remaining goals (displayed at the top), EasyCrypt
  Ext echoes this information in the minibuffer instead.

-----

# Tips and Tricks

The following gathers a few additional quality-of-life improvements you might
want to consider, either as complements to the features described above or
independently.

## Automatic Completion Popup (Corfu)

If you prefer completion suggestions to appear automatically as you type, you
can enable this behavior in Corfu by setting the `corfu-auto` customization
variable to `t`. In that case, you may also want to adjust a few other Corfu
settings, since the defaults are geared toward explicitly invoking completion.
Particularly, consider (1) setting `corfu-on-exact-match`
to `nil` to prevent Corfu from automatically inserting completions when
there is only single match (left), and (2) _unsetting_ some Corfu  keybindings
that may interfere with regular editing, e.g., `<up>`, `<down>` and `RET`.

Below is an example `use-package` configuration for Corfu that incorporates
these changes. You can further customize Corfu’s behavior (such as the delay
before the popup appears) via other variables; see [the Corfu
repository](https://github.com/minad/corfu) for details.

```emacs-lisp
(use-package corfu
  :ensure t

  :init
  ;; Disable auto-insertion
  (setopt corfu-on-exact-match nil)

  ;; Enable automatic completion popup
  (setopt corfu-auto t)

  :config
  ;; Unset default keybindings that may interfere with editing
  (keymap-unset corfu-map "<remap> <previous-line>")
  (keymap-unset corfu-map "<remap> <next-line>")
  (keymap-unset corfu-map "RET")
  (keymap-unset corfu-map "<up>")
  (keymap-unset corfu-map "<down>")

  ;; Set alternative keybindings for navigation/completion
  ;; (change these to whatever keybindings you prefer)
  (keymap-set corfu-map "M-p" #'corfu-previous)
  (keymap-set corfu-map "M-n" #'corfu-next)
  (keymap-set corfu-map "M-RET" #'corfu-insert)
```

## Documentation Popup (Corfu)

By default, Corfu displays completion documentation in a separate window when
requested (see [Keyword Completion and
Templates](#keyword-completion-and-templates)). The extension `corfu-popupinfo`
(included with Corfu) provides an alternative: it shows the documentation in a
popup next to the completion menu, either explicitly on request or automatically
after a short, configurable delay.

<p align="center">
  <img src="https://github.com/mmctl/easycrypt-ext/blob/assets/example-tempel-documentation-corfu-popup.gif" width="75%" alt="Demonstration of template documentation (with Corfu, popup)">
  <br>
  <em>Template documentation with Corfu (popup)</em>
</p>

The following `use-package` declaration enables `corfu-popupinfo`. For
additional configuration options, see [the Corfu
repository](https://github.com/minad/corfu).

```emacs-lisp
(use-package corfu-popupinfo
  :ensure nil ; Comes with Corfu

  :after corfu ; Load after Corfu

  :config
  ;; Activation
  (corfu-popupinfo-mode 1))
```

## Additional Completion Functions (Cape)

Although EasyCrypt Ext only deals with `cape-keyword`, Cape provides many other
completion functions you can use alongside it ([see the Cape
repository](https://github.com/minad/cape)). A particularly useful one is
`cape-dabbrev`, which suggests completions based on words in the current buffer
(and in other buffers with the same mode, e.g., all your open EasyCrypt
buffers). This means it can also complete any axioms, lemmas, and operators you
have defined or used earlier, which is great if you don't always remember their
exact names.

The snippet below extends the original configuration (see [Extras](#extras)) by
adding `cape-dabbrev` after `cape-keyword` in `completion-at-point-functions`.
The order matters: Emacs will only use the first completion function that
returns results. This means that if you put `cape-dabbrev` before
`cape-keyword`, keyword completions would be hidden whenever a buffer word
matches.[^10]

[^10]: To avoid this, Cape also provides `cape-capf-super`, a way to combine multiple
completion functions into one, so they are tried together rather than
sequentially.

```emacs-lisp
(use-package easycrypt-ext-cape
    :ensure nil ; Comes with EasyCrypt Ext

    :hook
    ;; Ensure Cape integration loads whenever EasyCrypt Ext loads
    (easycrypt-ext-mode . easycrypt-ext-mode-cape-setup)

    :config
    ;; Add (resp. remove) `cape-keyword' and `cape-dabbrev` to (resp. from)
    ;; the functions used for completion whenever EasyCrypt Ext loads (resp. unloads)
    (defun setup-ece-cape-keyword ()
        (if easycrypt-ext-mode
            (progn
                (add-hook 'completion-at-point-functions #'cape-dabbrev nil t)
                (add-hook 'completion-at-point-functions #'cape-keyword nil t))
          (remove-hook 'completion-at-point-functions #'cape-dabbrev t)
          (remove-hook 'completion-at-point-functions #'cape-keyword t)))
    (add-hook 'easycrypt-ext-mode-hook #'setup-ece-cape-keyword))
```

If you use `cape-dabbrev`, it’s also worth checking the options
`dabbrev-upcase-means-case-search`, `dabbrev-case-distinction`, and
`dabbrev-case-replace`, which control how case sensitivity and case preservation
are handled during completion.

## Enhanced Imenu (Consult)

[Consult](https://github.com/minad/consult) is another great package by the
author of Cape, Tempel, and Corfu. One of the many features it provides is an
enhanced Imenu with live preview of items and smoother navigation between
categories. To make this work well in non-standard modes, a bit of extra setup
is needed. The details are out of scope here, but the snippet below provides a
ready-to-use setup: simply add it to the `:config` block of your `use-package`
declaration for `easycrypt-ext`.

```emacs-lisp
(with-eval-after-load 'consult-imenu
    (add-to-list 'consult-imenu-config
                 '(easycrypt-mode :types
                    ((?t "Types" font-lock-type-face)
                     (?o "Operators" font-lock-function-name-face)
                     (?c "Constants" font-lock-constant-face)
                     (?m "Modules" font-lock-property-use-face)
                     (?M "Module Types" font-lock-type-face)
                     (?a "Axioms" font-lock-builtin-face)
                     (?l "Lemmas" font-lock-keyword-face)
                     (?T "Theories" font-lock-type-face)))))
```
