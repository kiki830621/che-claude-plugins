---
name: inbox
description: Show Things 3 Inbox - unprocessed tasks
allowed-tools:
  - mcp__che-things-mcp__get_inbox
---

# Things 3 Inbox

Show all unprocessed tasks from the Inbox:

1. Use `get_inbox` to retrieve all inbox items
2. Present each task with:
   - Task name
   - Creation date
   - Notes preview (if any)
   - Tags (if any)

Suggest actions the user might want to take:
- Move to a project
- Schedule for a specific day
- Add to an area
- Set as Someday/Maybe
