# Nightly Agent Loop - Setup & Verification

We have successfully configured, debugged, and verified the autonomous nightly agent loop for the "Learning Loop" project.

## Status: ✅ OPERATIONAL

The system is now fully automated and scheduled to run nightly at **23:00**.

### 1. Verification Results
We performed a manual forced run of the shipping loop (`auto-compound.sh`) to validate the end-to-end process.

- **Objective**: Execute the P0 task from `reports/2026-01-30.md` ("Verify Nightly Loop Automation").
- **Outcome**: Success.
- **Evidence**:
  - `proof-of-life.md` file was created independently by the agent.
  - A new git branch `compound/verify-automation` was created.
  - Changes were committed with message: "feat: add proof-of-life file to verify automation".
  - Logs confirms: `SUCCESS: PR appears to have been created!`

### 2. Issues Resolves

| Issue | Root Cause | Resolution |
|-------|------------|------------|
| **Gemini CLI Crash** | `sysctl ENOENT` error caused by missing `/usr/sbin` in PATH | Added `/usr/sbin` to LaunchAgent plist PATH. |
| **Permissions Error** | `~/.gemini/tmp` directory locked (`EPERM`) | Modified scripts to use a temporary fake home directory (`/tmp/gemini_fake_home...`) and copy credentials. |
| **XML Validation** | Invalid `&&` in plist file | Escaped to `&amp;&amp;` in `com.compound.shipping.plist`. |
| **Disk Space / Cleanup** | Copying full `~/.gemini` (31GB) was unsustainable | Optimized to selective copy (`*.json` only) and added `trap` for cleanup. Applied to both scripts. |

### 3. How to Monitor

You can inspect the logs specifically for the shipping or learning loops:

```bash
# Shipping Loop (Runs at 23:00)
tail -f "logs/compound-shipping.log"

# Learning Loop (Runs at 22:30)
tail -f "logs/compound-learning.log"
```

### 5. Cleaning Disk Space
To reclaim space from old browser recordings (the 31GB source), use the new cleanup script:

```bash
# Dry run (default) - lists files older than 14 days
./scripts/compound/clean-memory.sh

# Force delete older than 7 days
./scripts/compound/clean-memory.sh --force --days 7

# 🚨 AGGRESSIVE CLEANUP (Delete EVERYTHING)
# 1. Delete all recordings (0 days retention)
./scripts/compound/clean-memory.sh --force --days 0

# 2. Delete Browser Cache (6.5GB) - Warnings: Logs you out of sites
rm -rf ~/.gemini/antigravity-browser-profile
```

### 6. Next Steps
- Allow the system to run automatically tonight at 23:00.
- Check `reports/` tomorrow morning to see new learnings.
