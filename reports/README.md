# Reports Directory

This directory contains daily reports that the **Shipping Loop** analyzes to identify priorities.

## Report Format

Create markdown files with the naming convention: `YYYY-MM-DD.md`

Example: `2026-01-29.md`

## Recommended Structure

```markdown
# Daily Report - [Date]

## Metrics
- DAU: [number]
- Error rate: [percentage]
- Performance: [p50/p95 latency]

## Priorities
1. **[P0] [Issue Name]**: [Brief description]
2. **[P1] [Issue Name]**: [Brief description]

## User Feedback
- [Summarize any user complaints or requests]

## Technical Debt
- [List any accumulating issues]

## Notes
- [Any other relevant context]
```

## Automation Ideas

You can automate report generation by:
1. **Cron job** that pulls metrics from your monitoring (Datadog, Sentry, etc.)
2. **GitHub Action** that summarizes issues and PRs
3. **Slack bot** that compiles user feedback

## Example Minimal Report

```markdown
# Daily Report - 2026-01-29

## Priorities
1. **[P0] Fix login timeout**: Users report 30s+ login times
2. **[P1] Update dependencies**: 5 packages have security advisories

## Notes
- Deploy to staging passed all tests
```
