<!-- markdownlint-disable -->

# Hardening Report: always-further--runseal/v0.2.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **always-further--runseal/v0.2.2** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A ${{ ... }} expression is directly interpolated inside a `run:` shell command string. In the 'Setup Runseal' step, the run block is: `run: bash "${{ github.action_path }}/setup.sh"`. The `${{ github.action_path }}` value is substituted by the Actions runner before the shell ever sees the command, meaning any special characters in the path could be interpreted by the shell. All `${{ ... }}` expressions inside `run:` blocks are script-injection risks and should instead be passed via an `env:` variable and referenced as `$ENV_VAR` in the shell.

Locations:

- `action.yml:44`

### github-env-injection (severity: high)

The `inputs.runseal-version` and `inputs.nono-version` values are passed into setup.sh via the env vars `RUNSEAL_VERSION` and `NONO_VERSION`. Inside setup.sh, these values flow through `resolve_version()`/`strip_v()` into the `install_dir` variable (e.g. `install_dir="${INSTALL_ROOT}/${name}/${version}/${target}"`), which is then written directly to `$GITHUB_PATH` with `echo "${install_dir}" >> "${GITHUB_PATH}"`. No `printf '%s' ... | tr -d '\n\r'` sanitization is applied before the write. An attacker-controlled version string containing embedded newlines could inject arbitrary entries into GITHUB_PATH, potentially hijacking subsequent tool lookups. This affects all three GITHUB_PATH write sites in setup.sh.

Locations:

- `setup.sh:97`
- `setup.sh:112`
- `setup.sh:130`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

1. action.yml line 44: Replaced `bash "${{ github.action_path }}/setup.sh"` with `bash "$RUNSEAL_ACTION_PATH/setup.sh"` — the RUNSEAL_ACTION_PATH env var was already defined in the step's env block, so no new env entry was needed. This eliminates the direct ${{ }} interpolation in the run: shell string.

2. setup.sh lines 97, 112, 130: Replaced all three `echo "${install_dir}" >> "${GITHUB_PATH}"` calls with `printf '%s' "${install_dir}" | tr -d '\n\r' >> "${GITHUB_PATH}"` followed by `printf '\n' >> "${GITHUB_PATH}"`. This sanitizes attacker-controlled version strings (flowing through resolve_version/strip_v into install_dir) before they are written to GITHUB_PATH, preventing newline injection that could hijack subsequent tool lookups.

