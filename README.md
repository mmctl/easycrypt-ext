# EasyCrypt Extensions for Emacs (Proof-General)

---

# This project is still WIP

---

At its core, [EasyCrypt](https://www.easycrypt.info/) is an interactive theorem
prover with a front-end implemented in [Proof General](https://proofgeneral.github.io/),
a generic framework for implementing such front-ends.
This package aims to add useful extensions to this EasyCrypt front-end.
Key features include the following.
- Improved (but still ad-hoc) indentation.
- Keyword completion; requires [`cape`](https://github.com/minad/cape), specifically `cape-keyword`.
- Templates ("code snippets"); requires [`tempel`](https://github.com/minad/tempel).
- Informative templates ("code snippets"); requires
  [`tempel`](https://github.com/minad/tempel). Contrary to "regular"
  templates, which automatically insert boilerplate code and allow you to
  quickly navigate and fill in fields, informative templates mainly aim to
  provide guidance on the type of information expected in each field. These
  templates serve more as documentation or reminders rather than just code
  insertion tools.
- Executing proof shell commands through keybindings or mouse clicks
  (eliminating the need to manually type the corresponding commands).
  Supported commands are `print`, `search`, and `locate`.
  This functionality is also made accessible through the
  appropriate menus (menu bar and mode line).
- Executing command line (sub)commands through keybindings.
  Supported commands are `compile`, `docgen`, `runtest`, `why3config`,
  and `--help` (which is actually an option, but you get the point).
  Where relevant, this functionality is extended to the directory/project
  level, enabling you to execute a (sub)commands for each EasyCrypt
  file in a directory (tree).
  This functionality is also made accessible through the
  appropriate menus (menu bar and mode line).

These features are (partially) implemented through three minor modes, one
for each of the major modes provided by the existing front-end:
- `easycrypt-ext-mode`, for `easycrypt-mode`;
- `easycrypt-ext-goals-mode`, for `easycrypt-goals-mode`; and
- `easycrypt-ext-response-mode`, for `easycrypt-response-mode`.

The default values for the user options are customizable via Emacs's
usual customization interface, but all options can additionally
be enabled/disabled/toggled via commands accessible through
key bindings and the appropriate menus (menu bar and mode line).

> **Note:** The current version of this package requires Emacs version 29.1 or
> greater.

## Getting Started

To get started with this package, follow these simple steps:
1. Download the material from this repository.[^1]
2. Copy relevant parts from the `init.el` file to your Emacs initialization
   file,[^2] adjusting any settings to your preference.

The `init.el` file is thoroughly commented to guide you in deciding which sections
are necessary and which ones you might want to customize. It can also serve as a
fully functional standalone initialization file, which may be useful
you haven’t customized Emacs yet (or don't care about your current configuration).

In any case, make sure that you check out parts marked
with "*CHECK*" and "*CONSIDER*" in `init.el`. The former marks parts
that are critical for the package to work; the latter
marks parts that provide optional or additional settings that may be useful.

[^1]: The package files are expected to be located in `local/easycrypt-ext/`,
    relative to your Emacs directory by default. You can find your Emacs
    directory by opening Emacs, pressing `C-h v`, typing "user-emacs-directory",
    and hitting enter. If you deviate from the default location, be sure to
    update the `ECE_DIR` constant.

[^2]: To find your Emacs initialization file, open Emacs, press `C-h v` (i.e.,
`Control + h` followed by `v`), type "user-init-file", and hit enter.

Once you've copied the necessary configuration, simply restart Emacs. Emacs will
automatically download the required packages and set everything up for you.
After that, just open an EasyCrypt file and start working!

## Options

## Commands
Below are the most relevant available commands and their default keybindings.
most commands can also be accessed through the corresponding menus in the menu
bar and mode line.

TODO: comment about finding documentation in Emacs and file
TODO

> To avoid conflicts with other keybindings (from Proof General or
> otherwise), all keybindings for this package begin with the prefix `C-c C-y`.
> Depending on your personal keybindings and how many Proof General
> keybindings you want to use, there may be (a lot) more convenient alternatives.
> An example customization is provided in `init.el`.

### Proof Shell

| Command             | Keybinding                      | Description                     |
|:--------------------|:--------------------------------|:--------------------------------|
| `ece-locate`        | `C-c C-y l` and `C-S-<mouse 2>` | `locate` item at point or click |
| `ece-print`         | `C-c C-y p` and `C-S-<mouse 1>` | `print` item at point or click  |
| `ece-search`        | `C-c C-y p` and `C-S-<mouse 3>` | `search` item at point or click |
| `ece-prompt-locate` | `C-c C-y L`                     | Prompt for item to `locate`     |
| `ece-prompt-print`  | `C-c C-y P`                     | Prompt for item to `print`      |
| `ece-prompt-search` | `C-c C-y S`                     | Prompt for item to `search`     |

### Executable (Command Line)

| Command               | Keybinding      | Description                                                                             |
|:----------------------|:----------------|:----------------------------------------------------------------------------------------|
| `ece-compile-file`    | `C-c C-y e c`   | `compile` (check) visited EasyCrypt file                                                |
| `ece-compile-dir`     | `C-c C-y e C`   | `compile` (check) EasyCrypt files in visited directory and its children                 |
| `ece-compile`         | `C-c C-y e C-c` | Prompt for EasyCrypt file(s) to `compile` (check)                                       |
| `ece-docgen-file`     | `C-c C-y e d`   | `docgen` (generate documentation) visited EasyCrypt file                                |
| `ece-docgen-dir`      | `C-c C-y e D`   | `docgen` (generate documentation) EasyCrypt files in visited directory and its children |
| `ece-docgen`          | `C-c C-y e C-d` | Prompt for EasyCrypt file(s) to `docgen` (generate documentation)                       |
| `ece-help`            | `C-c C-y e h`   | Print help (as output by `easycrypt --help`)                                            |
| `ece-runtest-dflt`    | `C-c C-y e r`   | `runtest` (test) using default test file and scenario (relative to visited directory)   |
| `ece-runtest`         | `C-c C-y e R`   | Prompt for configuration to use with `runtest` (test)                                   |
| `ece-why3config-dflt` | `C-c C-y e w`   | `why3config` (configure Why3) using default configuration file                          |
| `ece-why3config`      | `C-c C-y e W`   | Prompt for configuration file to use with `why3config` (configure Why3).                |

### Options

| Command                               | Keybinding      | Description                                                                     |
|:--------------------------------------|:----------------|:--------------------------------------------------------------------------------|
| `ece-toggle-indentation-local`        | `C-c C-y o i`   | Toggle enhanced indentation in current buffer                                   |
| `ece-enable-indentation`              | `C-c C-y o I`   | Enable enhanced indentation in all EasyCrypt Ext buffers                        |
| `ece-disable-indentation`             | `C-c C-y o C-i` | Disable enhanced indentation in all EasyCrypt Ext buffers                       |
| `ece-toggle-indentation-style-local`  | `C-c C-y o s`   | Toggle indentation style in current buffer                                      |
| `ece-toggle-keyword-completion-local` | `C-c C-y o k`   | Toggle keyword completion in current buffer                                     |
| `ece-enable-keyword-completion`       | `C-c C-y o K`   | Enable keyword completion in all EasyCrypt Ext buffers                          |
| `ece-disable-keyword-completion`      | `C-c C-y o C-k` | Disable keyword completion in all EasyCrypt Ext buffers                         |
| `ece-toggle-templates-local`          | `C-c C-y o t`   | Toggle templates in current buffer                                              |
| `ece-enable-templates`                | `C-c C-y o T`   | Enable templates in all EasyCrypt Ext buffers                                   |
| `ece-disable-templates`               | `C-c C-y o C-t` | Disable templates in all EasyCrypt Ext buffers                                  |
| `ece-toggle-templates-info-local`     | `C-c C-y o o`   | Toggle informative templates in current buffer                                  |
| `ece-enable-templates-info`           | `C-c C-y o O`   | Enable informative templates in all EasyCrypt Ext buffers                       |
| `ece-disable-templates-info`          | `C-c C-y o C-o` | Disable informative templates in all EasyCrypt Ext buffers                      |
| `ece-reset-to-defaults-local`         | `C-c C-y o r`   | Reset all EasyCrypt Ext settings to their defaults in current buffer            |
| `ece-disable-templates-info`          | `C-c C-y o R`   | Reset all EasyCrypt Ext settings to their defaults in all EasyCrypt Ext buffers |

### Miscellaneous
conditional:
- templates map
- indentation
