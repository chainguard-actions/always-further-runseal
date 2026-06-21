<!-- markdownlint-disable -->

# Hardening Report: always-further--runseal/v0.3.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **always-further--runseal/v0.3.2** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A ${{ }} expression is interpolated directly inside a `run:` shell command string. The step 'Setup Runseal' uses `run: bash "${{ github.action_path }}/setup.sh"`, embedding `${{ github.action_path }}` directly in the shell command. Any ${{ ... }} expression inside a run: block is a script-injection risk because the value is substituted by the YAML template engine before the shell ever sees it, bypassing shell quoting. The safe pattern is to use the `$GITHUB_ACTION_PATH` environment variable instead (which is already available as a pre-set env var in composite actions).

Locations:

- `action.yml:50`

### github-env-injection (severity: high)

The `install_release_binary` function in setup.sh writes `install_dir` to `$GITHUB_PATH` without sanitization. `install_dir` is constructed as `${INSTALL_ROOT}/${name}/${version}/${target}`, where `version` is derived from `RUNSEAL_VERSION` and `NONO_VERSION` — environment variables set directly from `inputs.runseal-version` and `inputs.nono-version` (user-controlled). A caller can inject newline characters into these inputs, which would allow writing arbitrary entries to `$GITHUB_PATH` and hijacking the PATH. The required sanitization step (`printf '%s' "$install_dir" | tr -d '\n\r'`) is absent before each `echo "${install_dir}" >> "${GITHUB_PATH}"` call. This affects all three GITHUB_PATH write sites in setup.sh (inside `install_release_binary` for the cached-binary path, the fresh-install path, and inside `install_runseal_from_source`).

Locations:

- `setup.sh:160`
- `setup.sh:178`
- `setup.sh:200`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

1. action.yml: Replaced `bash "${{ github.action_path }}/setup.sh"` with `bash "$GITHUB_ACTION_PATH/setup.sh"` to eliminate the template expression from the run: shell command, using the pre-set GITHUB_ACTION_PATH environment variable instead.
2. setup.sh: Added `safe_install_dir="$(printf '%s' "${install_dir}" | tr -d '\n\r')"` before all three GITHUB_PATH write sites (cached binary path in install_release_binary, fresh install path in install_release_binary, and in install_runseal_from_source), and updated both the GITHUB_PATH echo and the PATH export to use the sanitized value. This prevents newline injection via user-controlled version inputs.

