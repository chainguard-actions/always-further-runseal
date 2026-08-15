#!/bin/bash
# Fake nono for act testing - runs command without Landlock sandboxing
if [ "$1" = "--version" ]; then echo "nono 0.0.0-fake"; exit 0; fi
found_sep=false
cmd_args=()
for arg in "$@"; do
  if [ "$found_sep" = "true" ]; then
    cmd_args+=("$arg")
  elif [ "$arg" = "--" ]; then
    found_sep=true
  fi
done
if [ "${#cmd_args[@]}" -eq 0 ]; then echo "nono: no command" >&2; exit 1; fi
exec "${cmd_args[@]}"
