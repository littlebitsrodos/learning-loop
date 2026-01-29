# 🌙 Nightly Agent Loop for Gemini CLI

A self-improving AI engineering system that **learns from your daily work** and **ships code while you sleep**.

Based on [Ryan Carson's implementation](https://x.com/ryancarson/status/2016520542723924279), adapted for Google's Gemini CLI.

## How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   5:00 PM    ────────────────────────────────────────────►     │
│   Mac stays awake (caffeinate)                        2:00 AM  │
│                                                                 │
│              ┌──────────────┐          ┌──────────────┐        │
│              │ LEARNING     │          │ SHIPPING     │        │
│              │ 10:30 PM     │   ──►    │ 11:00 PM     │        │
│              │              │          │              │        │
│              │ • Review git │          │ • Read GEMINI.md      │
│              │ • Extract    │          │ • Analyze reports     │
│              │   patterns   │          │ • Identify #1 priority│
│              │ • Update     │          │ • Implement code      │
│              │   GEMINI.md  │          │ • Open PR             │
│              └──────────────┘          └──────────────┘        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Quick Start

### 1. Copy to Your Project

```bash
# Copy the scripts directory to your project
cp -r /path/to/this/scripts/compound /path/to/your/project/scripts/

# Or clone fresh
git clone https://github.com/youruser/nightly-agent-loop.git
cp -r nightly-agent-loop/scripts/compound /path/to/your/project/scripts/
```

### 2. Install LaunchAgents

```bash
cd /path/to/your/project
./scripts/compound/setup.sh .
```

### 3. Test (Dry Run)

```bash
# Test learning loop
./scripts/compound/daily-compound-review.sh --dry-run

# Test shipping loop
./scripts/compound/auto-compound.sh --dry-run
```

### 4. Create a Report

Create `reports/YYYY-MM-DD.md` with priorities:

```markdown
# Daily Report - 2026-01-29

## Priorities
1. **[P0] Fix login timeout**: Users report 30s+ login times
2. **[P1] Update deps**: 5 packages have security advisories
```

## Directory Structure

```
your-project/
├── scripts/
│   └── compound/
│       ├── daily-compound-review.sh    # Learning loop
│       ├── auto-compound.sh            # Shipping loop
│       ├── setup.sh                    # LaunchAgent installer
│       ├── prompts/
│       │   ├── learning-prompt.md      # Template for learning
│       │   └── shipping-prompt.md      # Template for shipping
│       └── launchagents/
│           ├── com.compound.learning.plist
│           ├── com.compound.shipping.plist
│           └── com.compound.caffeinate.plist
├── reports/                            # Daily reports for priorities
│   └── README.md
└── logs/                               # Script output logs
```

## Configuration

Environment variables (set in scripts or shell):

| Variable | Default | Description |
|----------|---------|-------------|
| `PROJECT_DIR` | `$(pwd)` | Project root directory |
| `GEMINI_CLI` | `/usr/local/Cellar/node/25.4.0/bin/gemini` | Path to Gemini CLI |
| `MEMORY_FILE` | `~/.gemini/GEMINI.md` | Agent memory file |
| `REPORTS_DIR` | `$PROJECT_DIR/reports` | Where to find reports |
| `MAX_ITERATIONS` | `10` | Max loop iterations |
| `BRANCH_PREFIX` | `compound` | Prefix for feature branches |

## Troubleshooting

### Check if LaunchAgents are loaded

```bash
launchctl list | grep compound
```

### View logs

```bash
# Script logs
tail -f logs/compound-*.log

# LaunchAgent logs
tail -f /tmp/compound-*.log
```

### Manually trigger

```bash
# Unload and reload
launchctl unload ~/Library/LaunchAgents/com.compound.learning.plist
launchctl load ~/Library/LaunchAgents/com.compound.learning.plist
```

### Uninstall

```bash
./scripts/compound/setup.sh --uninstall
```

## Requirements

- **macOS** (uses `launchd` for scheduling)
- **Gemini CLI** (`npm install -g @google/gemini-cli`)
- **jq** (`brew install jq`)
- **Git** repository

## License

MIT - Use freely, contribute back!
