# AI Coding Agent Guide

Useful Linux shell scripts for DevOps, deployment, and server management.

## Current Structure
- [README.md](linux-utils/README.md) describes intent; scripts are not yet present in this repo snapshot.

## Conventions (when adding scripts)
- Use portable Bash (`#!/usr/bin/env bash`) and `set -euo pipefail`.
- Parameterize via env vars and flags; avoid hardcoding.
- Log to stderr for errors; return non-zero on failure.
- Keep scripts self-contained; minimal external dependencies.

## Suggested Layout
- `scripts/` for executable tools.
- `bin/` symlinks or wrappers, if needed.
- `docs/` for usage examples.

## Examples (patterns to follow)
- Health check: `curl --fail --silent --show-error` with retry.
- System info: `uname -a`, `df -h`, `free -m`, `ps aux --sort=-%mem | head`.
- Deployment helpers: rsync with `--delete --checksum`, atomic symlink swaps.

## Testing & Usage
- Lint with: `shellcheck scripts/*.sh`.
- Format with: `shfmt -w scripts` (optional).
- Make executable: `chmod +x scripts/<name>.sh`; run directly.

## Notes
- Document required permissions or sudo usage inline (`usage()` + comments).
- Prefer idempotent operations for deployment-related scripts.