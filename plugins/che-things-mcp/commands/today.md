---
name: today
description: Show today's tasks from Things 3
allowed-tools:
  - mcp__che-things-mcp__get_today
---

# Today's Tasks

Show the user their Things 3 tasks for today:

1. Use `get_today` to retrieve all tasks scheduled for today
2. Present tasks grouped by:
   - Projects (if any)
   - Areas (if any)
   - Loose tasks

Include for each task:
- Task name
- Due date (if set)
- Tags (if any)
- Notes preview (first line, if exists)

If there are no tasks, let the user know their day is clear in Things 3.
