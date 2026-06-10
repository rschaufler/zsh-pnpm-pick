# zsh-pnpm-pick

Fuzzy-pick a script from any package in a [pnpm](https://pnpm.io) workspace and
load the command **into your prompt** — editable, in your history, and visible
in your terminal title.

Unlike a plain runner, `ppick` does not execute the script for you. It pushes
the resolved command onto the zsh editor buffer (`print -z`), so you:

- see exactly what will run and can tweak flags before hitting Enter,
- get a real history entry (`pnpm --filter … run …`), and
- let your prompt's `preexec` set the terminal title from the running command.

```text
$ ppick
┌ Pick a script: (type to filter, ↑/↓ to move, enter to select) ─────────────┐
│ file-provider   dev          nest start --watch                            │
│ editorial-svc   build        nest build                                    │
│ adapter-wwa     dev:load     tsx src/load.ts                               │
└────────────────────────────────────────────────────────────────────────────┘
# after selecting:
$ pnpm --filter @scope/file-provider run dev▮      ← sitting in your prompt
```

## How it works

The picker (`bin/pnpm-pick`, a self-contained
[`uv`](https://docs.astral.sh/uv/) script) walks up from `$PWD` to the nearest
`pnpm-workspace.yaml`, reads its `packages:` globs, and collects every
`(package, script)` pair. You fuzzy-filter and select one; it writes
`pnpm --filter <pkg> run <script>` to a temp file. The `ppick` shell function
reads that file and `print -z`'s the command onto your prompt.

A child process can't type into its parent shell's line editor — only the shell
can. That's why this is a shell function plus a helper script rather than a
single binary: the temp file is the handoff, and `print -z` is the zsh builtin
that does the prompt-fill.

## Requirements

- **zsh** (uses the `print -z` builtin)
- [**uv**](https://docs.astral.sh/uv/) — runs the bundled Python picker and
  manages its dependencies automatically (no manual `pip install`)
- **pnpm** — the command it builds for you

## Install

### Oh My Zsh

```sh
git clone https://github.com/<you>/zsh-pnpm-pick \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-pnpm-pick"
```

Then add it to your plugin list in `~/.zshrc`:

```sh
plugins=(... zsh-pnpm-pick)
```

> Oh My Zsh requires the plugin entry, its directory, and the `.plugin.zsh`
> file to share one name — all three are `zsh-pnpm-pick`. The command it
> defines is `ppick` (unrelated to the plugin name).

Reload: `exec zsh`.

### Manual / other frameworks

Source the plugin file directly from `~/.zshrc`:

```sh
source /path/to/zsh-pnpm-pick/pnpm-pick.plugin.zsh
```

zinit:

```sh
zinit light <you>/zsh-pnpm-pick
```

antigen:

```sh
antigen bundle <you>/zsh-pnpm-pick
```

## Usage

```sh
ppick            # fuzzy over every (package, script) pair in the workspace
ppick dev        # pre-filter; if exactly one match, fills it without the picker
ppick file-prov  # pre-filter by substring (matches package name or script)
```

Pre-filter matching is a substring test against the displayed row
(`package  script  command`), so a single token works best.

## Configuration

| Variable            | Default                       | Purpose                                  |
| ------------------- | ----------------------------- | ---------------------------------------- |
| `PNPM_PICK_SCRIPT`  | `<plugin-dir>/bin/pnpm-pick`  | Path to the picker script.               |

Prefer a different command name? Alias it: `alias pp=ppick`.

## Standalone (no zsh)

The picker also works on its own — without `PNPM_PICK_OUTFILE` set it runs the
selected command directly instead of filling a prompt:

```sh
./bin/pnpm-pick dev
```

## License

[MIT](LICENSE)
