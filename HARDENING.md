<!-- markdownlint-disable -->

# Hardening Report: always-further--runseal/v0.3.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **always-further--runseal/v0.3.2** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `${{ github.action_path }}` expression is interpolated directly inside a `run:` shell command string in action.yml. Any `${{ ... }}` expression directly in a run: block is a script-injection risk as the value flows through YAML template substitution before the shell processes it. Offending line: `run: bash "${{ github.action_path }}/setup.sh"`

Locations:

- `action.yml:44`

### script-injection (severity: high)

Sub-rule (a): `${{ matrix.target }}` is interpolated directly inside `run:` shell command strings in the Build and Package steps of release.yml. `matrix.*` is an explicitly listed script-injection source. Offending lines: `run: cargo build --release --locked --target ${{ matrix.target }}` (line 35); `asset="runseal-v${version}-${{ matrix.target }}.tar.gz"` (line 41); `cp "target/${{ matrix.target }}/release/runseal" dist/pkg/runseal` (line 43).

Locations:

- `.github/workflows/release.yml:35`
- `.github/workflows/release.yml:41`
- `.github/workflows/release.yml:43`

### github-env-injection (severity: high)

In setup.sh (invoked by the composite action's Setup Runseal step), the variable `install_dir` is constructed from `${INSTALL_ROOT}/${name}/${version}/${target}` where `version` is resolved from the caller-supplied `RUNSEAL_VERSION` and `NONO_VERSION` environment variables (set from `inputs.runseal-version` and `inputs.nono-version`). This workflow-controlled value is written directly to `$GITHUB_PATH` in three locations without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). A malicious caller could inject newlines into the version string to write arbitrary entries into GITHUB_PATH.

Locations:

- `setup.sh:168`
- `setup.sh:196`
- `setup.sh:218`

### unpinned-uses (severity: high)

Multiple workflow files reference `always-further/runseal` using the mutable branch ref `@main` instead of a pinned 40-character commit SHA. This allows supply-chain attacks if the referenced branch is compromised. Failing references: `always-further/runseal@main` in github-token-smoke.yml (line 20) and `always-further/runseal@main` (×2) in test.yml (lines 18 and 34).

Locations:

- `.github/workflows/github-token-smoke.yml:20`
- `.github/workflows/test.yml:18`
- `.github/workflows/test.yml:34`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses

**Notes:**

Fixed all four findings:
1. script-injection (action.yml line 44): Replaced `bash "${{ github.action_path }}/setup.sh"` with `bash "$RUNSEAL_ACTION_PATH/setup.sh"` — the env block already sets RUNSEAL_ACTION_PATH from ${{ github.action_path }}, so no new env var was needed.
2. script-injection (release.yml lines 35, 41, 43): Added `env: MATRIX_TARGET: ${{ matrix.target }}` to both the Build and Package steps, then replaced all three `${{ matrix.target }}` occurrences in run: blocks with `$MATRIX_TARGET` / `${MATRIX_TARGET}`.
3. github-env-injection (setup.sh lines 168, 196, 218): Replaced all three `echo "${install_dir}" >> "${GITHUB_PATH}"` calls with `printf '%s' "${install_dir}" | tr -d '\n\r' >> "${GITHUB_PATH}"` followed by `printf '\n' >> "${GITHUB_PATH}"` to sanitize newlines before writing to GITHUB_PATH.
4. unpinned-uses: Pinned `always-further/runseal@main` to commit SHA `c63685a6fa2e8fd662fe753e96af076f085dfce0` in github-token-smoke.yml (1 occurrence) and test.yml (2 occurrences), preserving `# main` comments for readability.

