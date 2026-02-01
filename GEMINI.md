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


## Session Learnings (2026-01-31)

### Optimization & Robustness
- **Disk Space Bomb**: Discovered `~/.gemini` can grow to 30GB+ due to artifacts.
    - *Fix*: Modified agent scripts to perform **Selective Copy** (only `*.json`), ignoring the `antigravity` folder.
- **Permission Locks**: `~/.gemini/tmp` often gets locked with `EPERM`.
    - *Fix*: Implemented **Fake Home Strategy** (`GEMINI_HOME="/tmp/fake_home_..."`) to bypass system locks and ensure clean execution.
- **Maintenance**: Added `scripts/compound/clean-memory.sh` to prune old artifact recordings.


## Session Learnings (2026-02-01)

### LaunchAgent Operations
- **Loading vs Enabling**: Modern macOS uses `launchctl enable gui/$(id -u)/com.service.name` rather than `launchctl load -w`. The `load` command often fails with "Input/output error" on newer macOS versions.
- **Verification**: Use `launchctl print gui/$(id -u) | grep compound` to see enabled state (not `launchctl list` which only shows running processes).
- **Status Check**: A service showing `enabled` in `launchctl print` means it's registered and will run at its scheduled time.

### Gotchas
- **Log File Quarantine**: The `logs/` directory can have `com.apple.provenance` extended attribute (macOS sandbox quarantine) which blocks all write operations, even `touch` and `rm`.
    - *Fix*: Changed default `LOG_FILE` to `/tmp/compound-shipping.log` in `auto-compound.sh` to avoid sandbox conflicts.
- **Manual Caffeinate**: If you miss the scheduled caffeinate window (5 PM), manually run `caffeinate -i -t 18000 &` to keep Mac awake until the 11 PM agent run.

### Verification Workflow
Before relying on the nightly agent, run a **verification checklist**:
1. `launchctl print gui/$(id -u) | grep compound` → All 4 agents enabled
2. `pgrep caffeinate` → Caffeinate running
3. `./scripts/compound/auto-compound.sh --dry-run` → Full pipeline passes
4. Check `reports/YYYY-MM-DD.md` exists with P0/P1 priorities

### Architecture Improvement
- **Distributed Memory**: Updated `auto-compound.sh` and `daily-compound-review.sh` to load **both** memory files:
    - `~/.gemini/GEMINI.md` → Global protocols, philosophy, cross-project patterns
    - `$PROJECT_DIR/GEMINI.md` → Project-specific context, gotchas, learnings
- This ensures the nightly agent has full context awareness.
