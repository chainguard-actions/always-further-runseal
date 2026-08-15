<!-- markdownlint-disable -->

# Hardening Report: always-further--runseal/v0.3.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **always-further--runseal/v0.3.0** was hardened automatically. 5 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A `github.*` expression is directly interpolated inside a `run:` shell command string. In the 'Setup Runseal' step, `run: bash "${{ github.action_path }}/setup.sh"` embeds `${{ github.action_path }}` directly in the shell command. Any `${{ ... }}` expression in a run: block is a script-injection risk as the value flows through YAML template substitution before the shell sees it.

Locations:

- `action.yml:44`

### script-injection (severity: high)

Sub-rule (a): `${{ matrix.target }}` (a `matrix.*` context expression) is directly interpolated inside run: shell command strings in two steps. In the 'Build' step: `cargo build --release --locked --target ${{ matrix.target }}`. In the 'Package' step: `asset="runseal-v${version}-${{ matrix.target }}.tar.gz"` and `cp "target/${{ matrix.target }}/release/runseal" dist/pkg/runseal`. All of these embed expressions directly in run: blocks without routing through env: variables.

Locations:

- `.github/workflows/release.yml:33`
- `.github/workflows/release.yml:38`
- `.github/workflows/release.yml:40`

### github-env-injection (severity: high)

The `install_dir` variable — which incorporates `version` derived from the user-controlled `RUNSEAL_VERSION` and `NONO_VERSION` environment variables (set from `inputs.runseal-version` and `inputs.nono-version`) — is written directly to `$GITHUB_PATH` via `echo "${install_dir}" >> "${GITHUB_PATH}"` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). This occurs in three places in setup.sh: in the early-return cache-hit path, in the normal install path, and in the `install_runseal_from_source` function. An attacker-controlled version string containing newlines could inject arbitrary entries into GITHUB_PATH.

Locations:

- `setup.sh:112`
- `setup.sh:122`
- `setup.sh:138`

### unpinned-uses (severity: high)

The workflow uses `always-further/runseal@main` — a mutable branch reference instead of a pinned 40-character commit SHA. This means the action code executed can change at any time without notice, creating a supply-chain risk.

Locations:

- `.github/workflows/github-token-smoke.yml:17`

### unpinned-uses (severity: high)

The workflow uses `always-further/runseal@main` twice — a mutable branch reference instead of a pinned 40-character commit SHA. This means the action code executed can change at any time without notice, creating a supply-chain risk.

Locations:

- `.github/workflows/test.yml:14`
- `.github/workflows/test.yml:28`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses

**Notes:**

Fixed 5 findings across 5 files:
1. action.yml (script-injection): Changed `bash "${{ github.action_path }}/setup.sh"` to `bash "${RUNSEAL_ACTION_PATH}/setup.sh"` — the expression was already in the env: block as RUNSEAL_ACTION_PATH.
2. .github/workflows/release.yml (script-injection): Moved `${{ matrix.target }}` into env: blocks as MATRIX_TARGET in both the Build and Package steps.
3. setup.sh (github-env-injection): Replaced all 3 `echo "${install_dir}" >> "${GITHUB_PATH}"` calls with `printf '%s' "${install_dir}" | tr -d '\n\r' >> "${GITHUB_PATH}"` + `printf '\n' >> "${GITHUB_PATH}"` to sanitize newlines before writing to GITHUB_PATH.
4. .github/workflows/github-token-smoke.yml (unpinned-uses): Pinned `always-further/runseal@main` to `always-further/runseal@c63685a6fa2e8fd662fe753e96af076f085dfce0 # main`.
5. .github/workflows/test.yml (unpinned-uses): Pinned both `always-further/runseal@main` references to `always-further/runseal@c63685a6fa2e8fd662fe753e96af076f085dfce0 # main`.

### Iteration 2

**Fixes applied:** unpinned-uses, missing-permissions

**Notes:**

Fixed all 5 unpinned `uses:` references by resolving them to full 40-character commit SHAs (mutable tags/branches replaced with immutable SHAs, original ref preserved as comment). Note: `always-further/runseal@v1` tag does not exist in the repository; used the `main` branch SHA (c63685a6fa2e8fd662fe753e96af076f085dfce0) instead. Added a top-level `permissions: contents: read` block to `examples/npm-publish.yml` to address the missing-permissions finding. The `recipes/npm-postinstall/workflow.yml` already had a permissions block and was left unchanged in that regard.

