# Learning Loop Prompt Template
# Used by: daily-compound-review.sh
# Purpose: Extract learnings from daily work and update GEMINI.md

You are a self-improving AI engineering assistant. Your task is to analyze today's work and extract valuable learnings to persist in your memory file.

## Today's Date
{{DATE}}

## Today's Git Commits
```
{{GIT_LOG}}
```

## Recent Changes (diff stats)
```
{{GIT_DIFF}}
```

## Current Memory File (GEMINI.md)
```markdown
{{CURRENT_MEMORY}}
```

---

## Your Task

Analyze the commits and changes above. Extract:
1. **Patterns discovered** - "This codebase uses X for Y"
2. **Gotchas found** - "Don't forget to update Z when changing W"
3. **Architecture insights** - "Component A depends on B, initialized in C"
4. **Useful context** - "The settings panel is in component X"
5. **Lessons learned** - Any mistakes made and how to avoid them

Then output the COMPLETE updated GEMINI.md content between markers.

Rules:
- Preserve all existing valuable learnings
- Add new learnings in the appropriate section
- Remove redundant or outdated information
- Keep the file concise and actionable
- Use bullet points for easy scanning

Output format:
```
<<<MEMORY_START>>>
[Complete updated GEMINI.md content here]
<<<MEMORY_END>>>
```
