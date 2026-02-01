---
description: Extract learnings from current session and update GEMINI.md
---

# /compound Workflow

This workflow analyzes the current conversation and extracts valuable learnings to persist in your `GEMINI.md` memory file.

## Steps

1. **Review the Conversation**
   - Look at what we worked on in this session
   - Identify patterns, gotchas, architecture insights, and lessons learned

2. **Categorize Learnings**
   Extract insights in these categories:
   - **Patterns discovered**: "This codebase uses X for Y"
   - **Gotchas found**: "Don't forget to update Z when changing W"
   - **Architecture insights**: "Component A depends on B"
   - **Useful context**: "The settings panel is in component X"
   - **Lessons learned**: Mistakes made and how to avoid them

3. **Update GEMINI.md**
   - Read current `~/.gemini/GEMINI.md`
   - Add new learnings to appropriate sections
   - Keep existing valuable information
   - Remove redundant or outdated entries
   - Write updated file

4. **Confirm to User**
   - Show what was added
   - Explain why these learnings matter

## Example Output

After running /compound, you should see something like:

```
✅ Added to GEMINI.md:

### New Learnings from this Session
- **Pattern**: The nightly agent loop uses LaunchAgents for scheduling on macOS
- **Gotcha**: LaunchAgent PATH must include /usr/sbin for sysctl to work
- **Context**: Compound scripts are in `scripts/compound/` directory
```
