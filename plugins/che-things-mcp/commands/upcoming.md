---
name: upcoming
description: Show upcoming scheduled tasks from Things 3
allowed-tools:
  - mcp__che-things-mcp__get_upcoming
---

# Upcoming Tasks

Show tasks scheduled for the future:

1. Use `get_upcoming` to retrieve all upcoming scheduled tasks
2. Group tasks by date/week
3. Present in chronological order

For each task show:
- Task name
- Scheduled date
- Project (if any)
- Due date (if different from scheduled date)

This helps the user see what's coming up and plan ahead.
