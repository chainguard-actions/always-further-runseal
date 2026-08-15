#!/bin/bash
# Fake runseal for act testing - executes RUNSEAL_RUN via bash without sandboxing
if [ "$1" = "--version" ]; then echo "runseal 0.0.0-fake"; exit 0; fi
if [ "$1" = "run" ]; then
  if [ -z "${RUNSEAL_RUN:-}" ]; then
    echo "runseal: RUNSEAL_RUN is not set" >&2
    exit 1
  fi
  exec bash -c "${RUNSEAL_RUN}"
fi
echo "runseal: unknown command: $1" >&2
exit 1
