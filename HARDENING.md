<!-- markdownlint-disable -->

# Hardening Report: always-further--runseal/v0.3.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **always-further--runseal/v0.3.0** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violation: The 'Setup Runseal' step in action.yml directly interpolates `${{ github.action_path }}` inside the `run:` shell command string: `run: bash "${{ github.action_path }}/setup.sh"`. Any `${{ ... }}` expression interpolated directly into a run: block is processed by the YAML template engine before the shell sees it, allowing an attacker who controls the value to inject arbitrary shell commands. The safe alternative is to use the `$GITHUB_ACTION_PATH` environment variable (already available in composite actions) instead: `run: bash "$GITHUB_ACTION_PATH/setup.sh"`.

Locations:

- `action.yml:44`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script-injection in action.yml line 44: replaced `bash "${{ github.action_path }}/setup.sh"` with `bash "$GITHUB_ACTION_PATH/setup.sh"`. The `$GITHUB_ACTION_PATH` environment variable is automatically set by the GitHub Actions runner for composite actions and is the safe, injection-free alternative to the `${{ github.action_path }}` template expression in run: blocks.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed all three unsanitized writes to $GITHUB_PATH in setup.sh. Each `echo "${install_dir}" >> "${GITHUB_PATH}"` was replaced with `printf '%s' "${install_dir}" | tr -d '\n\r' >> "${GITHUB_PATH}"` followed by `printf '\n' >> "${GITHUB_PATH}"`. This strips any embedded newline or carriage-return characters from the user-controlled install_dir value (derived from runseal-version/nono-version inputs) before writing to GITHUB_PATH, preventing PATH injection via newline-containing version strings. All three locations were fixed: the early-return path in install_release_binary, the normal path in install_release_binary, and the path in install_runseal_from_source.

