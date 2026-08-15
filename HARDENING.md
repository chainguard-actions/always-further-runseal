<!-- markdownlint-disable -->

# Hardening Report: always-further--runseal/v0.3.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **always-further--runseal/v0.3.3** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A ${{ }} expression is directly interpolated inside a run: shell command string. In the 'Setup Runseal' step, `run: bash "${{ github.action_path }}/setup.sh"` embeds `github.action_path` directly into the shell command before the shell ever sees it. Any ${{ ... }} expression in a run: block is a script-injection risk because YAML template substitution happens before shell quoting. The safe pattern is to use the `$GITHUB_ACTION_PATH` environment variable instead (e.g., `run: bash "$GITHUB_ACTION_PATH/setup.sh"`).

Locations:

- `action.yml:46`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in action.yml line 46: replaced `bash "${{ github.action_path }}/setup.sh"` with `bash "$GITHUB_ACTION_PATH/setup.sh"`. The built-in GITHUB_ACTION_PATH environment variable is always available in GitHub Actions composite steps and provides the same value safely without template interpolation into the shell command string.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed all three locations in setup.sh where `install_dir` (derived from caller-controlled version inputs) was written directly to $GITHUB_PATH without newline sanitization. In each case, added `safe_install_dir="$(printf '%s' "${install_dir}" | tr -d '\n\r')"` and replaced the `echo "${install_dir}"` and `export PATH="${install_dir}:..."` references with `safe_install_dir`. The three locations were: (1) the cached-binary branch of `install_release_binary`, (2) the fresh-install branch of `install_release_binary`, and (3) `install_runseal_from_source`.

