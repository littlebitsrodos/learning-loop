# GEMINI.md for Learning Loop

## Overview
Autonomous Nightly Agent Loop infrastructure using Gemini CLI. This project provides the scripts and workflows to enable self-improving agents that learn from daily work and ship code nightly.

## Architecture
- **Scripts**: located in `scripts/compound/`.
- **Workflows**: `daily-compound-review.sh` (Learning) and `auto-compound.sh` (Shipping).
- **Automation**: Uses macOS `LaunchAgents` for scheduling.

## Context
- **Global Memory**: interacts with `~/.gemini/GEMINI.md`.
- **Reports**: stores daily reports in `reports/YYYY-MM-DD.md`.

## Session Learnings (2026-01-30)

### Architecture Insights
- **Progressive Disclosure**: Refactored global `GEMINI.md` from a monolithic file to a distributed system:
    - **Root (`~/.gemini/GEMINI.md`)**: Minimal configuration (~20 lines).
    - **Docs (`~/.gemini/docs/`)**: Shared protocols and standards.
    - **Projects (`[PROJECT_ROOT]/GEMINI.md`)**: Project-specific contexts.
- **Version Control**: Initialized git in `~/.gemini` to track changes to the agent's brain over time.

### Gotchas
- **LaunchAgents**: `launchctl list` status `0` means success/active.
- **Permissions**: The agent needs explicit access to project directories. Sandbox restrictions can prevent `ls` or `cp` across random directories (e.g., trying to access `~/Developer/other-project` from inside `Learning Loop` context).
- **Caffeinate**: Built-in macOS utility (`/usr/bin/caffeinate`). `-i` prevents system idle sleep. It cannot override a closed lid unless the Mac is plugged in and connected to an external display.

