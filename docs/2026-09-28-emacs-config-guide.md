# Emacs config guide

A quick tour of what this config gives you and how to use it. Written for Emacs 31 (emacs-plus) on macOS.

## Where things live

| File | Purpose |
| --- | --- |
| `symlinks/.config/emacs/early-init.el.symlink` | Startup tuning; runs before the first frame |
| `symlinks/.config/emacs/init.el.symlink` | Packages, general behavior, keys, server, apps |
| `config/emacs/config-theme.el` | Theme and mode line |
| `config/emacs/config-completion.el` | Minibuffer and in-buffer completion |
| `config/emacs/config-orgmode.el` | Org, org-roam, org-download |
| `config/emacs/config-prog.el` | Whitespace, tree-sitter, Eglot, Markdown, RST, XML |
| `config/emacs/config-ai.el` | vterm and Claude Code (see `2026-09-29-claude-code-ide-guide.org`) |
| `config/emacs/custom.el` | Written by `M-x customize`; don't edit by hand |

Packages install themselves on first launch. To add one, add a `use-package` block to the relevant module.

## Running Emacs

- A background Emacs daemon starts at login (`brew services`). Open **Emacs Client.app**, or run `emacsclient -c` in a terminal, to get a window connected to it. `emacsclient -t` opens one inside the terminal.
- **Emacs.app** runs a separate, standalone Emacs. It doesn't start its own server while the daemon is running.
- After changing the config, restart the daemon: `brew services restart emacs-plus`.
- In `M-x shell`, `M-x eshell`, and `M-!` commands, `$EDITOR` is the current Emacs, so `git commit` opens its message in a buffer. Finish with `C-c C-c`.

## Keys worth knowing

| Key | Action |
| --- | --- |
| `M-o` | Other window |
| `C-x C-m` | `M-x` |
| `C-w` / `C-x C-k` | Delete the previous word / cut the selection |
| `C-x p` … | Project commands: `f` find file, `p` switch project, `g` search, `b` switch buffer |
| `C-x n n` / `C-x n w` | Narrow to region / widen |
| `C-x g` / `C-x M-g` | Magit status / Magit command menu |
| `C-S-<arrow>` | Move the current buffer to the neighboring window |
| `C-c w` | Toggle whitespace display |

If you pause partway through a key sequence, **which-key** pops up the possible completions.

## Minibuffer completion

Minibuffer prompts (`M-x`, find file, switch buffer) show a vertical candidate list (**vertico**) with notes beside each candidate (**marginalia**).

- **Matching (orderless):** type space-separated fragments in any order. For example, `buf kill` matches `kill-buffer`. File paths match by prefix instead, so `~/d/c/e` finds `~/dotfiles/config/emacs`.
- **M-x** hides commands that don't apply to the current mode.
- **History** is saved between sessions, and recent choices sort first.

**Consult** commands add a live preview:

| Key | Action |
| --- | --- |
| `C-s` | Search lines in the buffer |
| `C-x b` | Switch buffer. The list also includes recent files and bookmarks; type `<` to narrow it to one kind. |
| `C-x 4 b` | Same, in another window |
| `M-s r` | Ripgrep the current project |
| `M-y` | Pick from the kill ring |
| `M-g g` | Go to line, with preview |
| `M-g i` | Jump to a definition or heading (imenu) |
| `C-x r b` | Jump to a bookmark |

**Embark** acts on the current candidate or the thing at point:

- `C-.` opens a menu of actions. For example, on a file candidate you can delete, rename, or copy its path.
- `C-.` then `E` exports a list of candidates to a buffer. Exported ripgrep or search results become a normal grep buffer, which you can make editable with `C-x C-q`.
- `C-h B` lists every key binding available in the current buffer, and you can search it.

## In-buffer completion

In-buffer completion suggestions (**corfu**) appear as a popup:

- **In code**, the popup appears on its own as you type.
- **In other buffers**, press `TAB` on an already-indented line, or `C-M-i` anywhere.
- Inside the popup, `TAB` or the arrow keys cycle through suggestions, `RET` inserts one, and `C-g` closes it.
- In Org, `C-M-i` completes org-roam note titles, so you can type part of a title and turn it into a link.

## Programming

- **Tree-sitter:** code files open in the newer tree-sitter major modes, which give faster, more accurate highlighting and indentation. Grammars are already installed for Python, Go, go.mod, YAML, JSON, Bash, TOML, and Dockerfile. For any other language, Emacs offers to download and compile the grammar the first time you open such a file.
- **Eglot (LSP)** starts automatically when a language server is installed. Supported servers:
  - Python: basedpyright, pyright, or pylsp
  - Go: gopls (the only one installed now)
  - YAML: yaml-language-server
  - Bash: bash-language-server
  - JSON: vscode-json-language-server
  - Markdown: marksman
- **Using Eglot:**
  - `M-.` / `M-,` jump to a definition and back.
  - `M-x eglot-rename` renames a symbol, `M-x eglot-code-actions` offers fixes, and `M-x eglot-format` reformats.
  - `M-x flymake-show-buffer-diagnostics` lists errors.
  - Eglot shuts the server down when you close the project's last buffer.
- **Whitespace:** trailing whitespace is highlighted in code and removed on save. Indentation uses spaces.

## Writing

- **Markdown:** `.md` files open in markdown-mode, and `README.md` opens in the GitHub-flavored variant. Saving checks that parentheses are balanced.
- **reStructuredText:** 4-space indents, with preferred heading adornments of `=` over-and-under, then `~`, `-`, `+`, and so on.
- **XML:** `.xml`, `.xsl`, `.xhtml`, and Mallard `.page` files open in nxml-mode.
- **Line wrapping:** text buffers wrap automatically at 100 columns. Sentences end with a single space.

## Org

| Key | Action |
| --- | --- |
| `C-c a` | Agenda (files in `~/org`) |
| `C-c l` | Store a link to the current location |
| `C-c b` | Switch to an Org buffer |
| `C-c n f` / `C-c n i` | Find or create a roam note / insert a link to one |
| `C-c n c` / `C-c n j` | Roam capture / today's daily note |
| `C-c n l` | Toggle the backlinks buffer |
| `C-c n a` / `C-c n t` / `C-c n o` | Add an alias / add a tag / add an ID to the heading |

- **TODO states:** TODO → NEXT → WAITING → DONE. Completion times are logged into a drawer.
- **Images:** drag an image into an Org buffer to save and link it (org-download).
- **`.txt` files** open in Org mode.

## Everyday behavior

- **Remembering state:**
  - Recent files are remembered and show up in `C-x b`.
  - Files reopen at the position where you left them.
  - Buffers, including Dired, reload when their file changes on disk.
- **Prompts:** yes/no questions take a single `y` or `n`.
- **Scrolling:** smooth trackpad scrolling in GUI frames.
- **Backup and auto-save files** go in `~/.config/emacs/backups/` and `~/.config/emacs/auto-save/`, not next to your files.
- **Dired** uses GNU `ls` (`gls`), with human-readable sizes.

## Theme

The theme is **Modus Vivendi** (dark), which is built into Emacs. `M-x modus-themes-toggle` switches to Modus Operandi (light). The mode line uses **moody** for tab-style buffer names, and **minions** collapses minor modes into a single `;-)` menu.

## Maintenance

- `M-x package-upgrade-all` upgrades every package.
- `M-x package-autoremove` deletes packages the config no longer uses.
- To troubleshoot startup, uncomment `(setq debug-on-error t)` at the top of `init.el`, or run `emacs --debug-init`.
