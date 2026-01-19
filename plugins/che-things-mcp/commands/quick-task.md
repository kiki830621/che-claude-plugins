---
name: quick-task
description: Quickly add a task to Things 3 from natural language
allowed-tools:
  - mcp__che-things-mcp__add_todo
  - mcp__che-things-mcp__get_projects
  - mcp__che-things-mcp__get_areas
---

# Quick Task Creation

Parse the user's natural language input and create a task in Things 3.

## Parsing Rules

1. **Task name**: The main content of the input
2. **Scheduling**: Look for keywords like:
   - "today", "tonight" → when: "today"
   - "tomorrow" → when: "tomorrow"
   - "someday", "eventually" → when: "someday"
   - Specific dates → due_date parameter
3. **Project**: Look for "for [project]" or "in [project]"
4. **Tags**: Look for "#tag" patterns

## Examples

- "Buy groceries tomorrow" → Task "Buy groceries", when: "tomorrow"
- "Call mom today" → Task "Call mom", when: "today"
- "Review report for Work project" → Task "Review report", project: "Work"
- "Someday learn Spanish" → Task "learn Spanish", when: "someday"

## Process

1. Parse the input for task details
2. If a project is mentioned, use `get_projects` to find the matching project
3. Create the task with `add_todo` (use `project: ""` if no project)
4. Confirm creation with task details
