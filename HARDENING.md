<!-- markdownlint-disable -->

# Hardening Report: always-further--runseal/v0.3.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **always-further--runseal/v0.3.4** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): the 'Setup Runseal' step puts a GitHub Actions expression directly into a run: block: `run: bash "${{ github.action_path }}/setup.sh"`. To fix it, use the env var instead: `bash "$GITHUB_ACTION_PATH/setup.sh"` (or the existing RUNSEAL_ACTION_PATH env var).

Locations:

- `action.yml:54`

### script-injection (severity: high)

Sub-rule (a): the 'Run sealed command' step puts a GitHub Actions expression directly into a run: block: `run: bash "${{ github.action_path }}/scripts/run-sealed.sh"`. To fix it, use `bash "$GITHUB_ACTION_PATH/scripts/run-sealed.sh"`.

Locations:

- `action.yml:63`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In action.yml, two run: lines inserted ${{ github.action_path }} straight into the shell command, in the 'Setup Runseal' and 'Run sealed command' steps. Both now use "$GITHUB_ACTION_PATH" instead. The runner sets this variable to the same directory, and both steps already use shell: bash, so the double-quoted form is correct. Nothing else changed. I didn't run the action to check this.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Added an append_github_path helper to setup.sh. It strips \n and \r with printf '%s' | tr -d '\n\r' before appending to $GITHUB_PATH. The three direct echo writes (cached release, fresh release, source build) now call it. The value is captured into a variable first, so errexit behaves the same. Nothing else changed.

