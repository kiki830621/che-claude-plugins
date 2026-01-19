---
name: projects
description: List all Things 3 projects with task counts
allowed-tools:
  - mcp__che-things-mcp__get_projects
  - mcp__che-things-mcp__get_areas
---

# Things 3 Projects Overview

Show all projects with their status and task counts:

1. Use `get_projects` to retrieve all projects
2. Use `get_areas` to get area information for grouping
3. Present projects grouped by area:
   - Active projects (with pending task count)
   - On-hold/Someday projects

For each project show:
- Project name
- Number of pending tasks
- Area (if any)
- Status (active, someday, etc.)

Offer quick actions:
- View tasks in a project
- Add a task to a project
- Show completed projects (Logbook)
