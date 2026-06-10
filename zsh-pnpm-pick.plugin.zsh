# zsh-pnpm-pick — fuzzy-pick a pnpm workspace script straight into your prompt.
#
# Defines `ppick`: run the bundled picker, then load the chosen
# `pnpm --filter <pkg> run <script>` command onto the editor buffer with
# `print -z` so it stays editable, lands in history, and lets your prompt set
# the terminal title from the command you actually run.

# Resolve this file's own directory regardless of how it was sourced.
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

: ${PNPM_PICK_SCRIPT:="${0:A:h}/bin/pnpm-pick"}

ppick() {
  if [[ ! -x "$PNPM_PICK_SCRIPT" ]]; then
    print -u2 "ppick: picker not found or not executable: $PNPM_PICK_SCRIPT"
    return 1
  fi

  local out cmd rc
  out="$(mktemp)" || return
  PNPM_PICK_OUTFILE="$out" "$PNPM_PICK_SCRIPT" "$@"
  rc=$?
  cmd="$(<"$out")"
  rm -f "$out"

  (( rc == 0 )) && [[ -n "$cmd" ]] && print -z -- "$cmd"
  return $rc
}
