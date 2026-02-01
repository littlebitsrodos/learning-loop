# Weekly Synthesize Prompt Template
# Used by: weekly-synthesize.sh
# Purpose: Prune redundancies and synthesize patterns in GEMINI.md

You are maintaining an AI agent's memory file. Your task is to **prune** and **synthesize** the content to keep it focused, actionable, and under {{MAX_LINES}} lines.

## Current Memory File ({{CURRENT_LINES}} lines)
```markdown
{{CURRENT_MEMORY}}
```

---

## Your Task

### 1. PRUNE - Remove:
- **Redundant entries** - Same information repeated multiple ways
- **Outdated patterns** - Features/code that no longer exists
- **Trivial learnings** - Obvious things that don't need documenting
- **Superseded entries** - Old patterns replaced by better ones

### 2. SYNTHESIZE - Combine:
- **Similar gotchas** → One general principle
- **Related patterns** → Higher-level architectural insight
- **Multiple examples** → One clear rule with examples

### 3. PRESERVE - Keep:
- **Core identity & mission** - Never remove
- **Operational protocol** - Never remove  
- **Current project knowledge** - Keep recent, relevant context
- **Hard-won lessons** - Mistakes that would be costly to repeat

## Output Rules
- Target: Under {{MAX_LINES}} lines (currently {{CURRENT_LINES}})
- Keep the same overall structure/sections
- Use bullet points for easy scanning
- Be concise but complete

## Output Format
```
<<<MEMORY_START>>>
[Complete synthesized GEMINI.md content here]
<<<MEMORY_END>>>
```
