---
name: task-management
description: Comprehensive guide for Things 3 task management via che-things-mcp. Use when user asks about tasks, todos, projects, or GTD workflow.
allowed-tools:
  - mcp__che-things-mcp__get_inbox
  - mcp__che-things-mcp__get_today
  - mcp__che-things-mcp__get_upcoming
  - mcp__che-things-mcp__get_anytime
  - mcp__che-things-mcp__get_someday
  - mcp__che-things-mcp__get_logbook
  - mcp__che-things-mcp__get_projects
  - mcp__che-things-mcp__get_areas
  - mcp__che-things-mcp__get_tags
  - mcp__che-things-mcp__add_todo
  - mcp__che-things-mcp__update_todo
  - mcp__che-things-mcp__complete_todo
  - mcp__che-things-mcp__delete_todo
  - mcp__che-things-mcp__search_todos
  - mcp__che-things-mcp__add_project
  - mcp__che-things-mcp__update_project
  - mcp__che-things-mcp__delete_project
  - mcp__che-things-mcp__add_area
  - mcp__che-things-mcp__update_area
  - mcp__che-things-mcp__delete_area
  - mcp__che-things-mcp__add_tag
  - mcp__che-things-mcp__update_tag
  - mcp__che-things-mcp__delete_tag
  - mcp__che-things-mcp__move_todo
  - mcp__che-things-mcp__move_project
  - mcp__che-things-mcp__cancel_todo
  - mcp__che-things-mcp__cancel_project
  - mcp__che-things-mcp__show_todo
  - mcp__che-things-mcp__show_project
  - mcp__che-things-mcp__show_list
  - mcp__che-things-mcp__show_quick_entry
  - mcp__che-things-mcp__get_selected_todos
  - mcp__che-things-mcp__get_todos_in_project
  - mcp__che-things-mcp__get_todos_in_area
  - mcp__che-things-mcp__get_projects_in_area
  - mcp__che-things-mcp__create_todos_batch
  - mcp__che-things-mcp__complete_todos_batch
  - mcp__che-things-mcp__delete_todos_batch
  - mcp__che-things-mcp__move_todos_batch
  - mcp__che-things-mcp__update_todos_batch
  - mcp__che-things-mcp__add_checklist_items
  - mcp__che-things-mcp__set_checklist_items
  - mcp__che-things-mcp__edit_todo
  - mcp__che-things-mcp__edit_project
  - mcp__che-things-mcp__empty_trash
  - mcp__che-things-mcp__log_completed_now
  - mcp__che-things-mcp__set_auth_token
  - mcp__che-things-mcp__check_auth_status
---

# Things 3 Task Management

This skill provides comprehensive guidance for managing tasks in Things 3 using the che-things-mcp server.

## Things 3 Concepts

### Lists (Built-in)
| List | Description | Tool |
|------|-------------|------|
| Inbox | Unprocessed tasks | `get_inbox` |
| Today | Tasks for today | `get_today` |
| Upcoming | Scheduled for future | `get_upcoming` |
| Anytime | Available anytime | `get_anytime` |
| Someday | Deferred tasks | `get_someday` |
| Logbook | Completed tasks | `get_logbook` |

### Organization
- **Areas**: High-level life categories (Work, Personal, Health)
- **Projects**: Goal-oriented containers with tasks
- **Tags**: Cross-cutting labels for filtering

## API Patterns

### Creating Tasks

**IMPORTANT**: The `project` parameter is **required** for `add_todo`. Use empty string `""` if not assigning to a project.

```
# Task in a project
add_todo(name: "Review report", project: "Work")

# Task without a project (explicit)
add_todo(name: "Buy groceries", project: "")

# Task in an area (not in a project)
add_todo(name: "Call mom", project: "", area: "Personal")
```

### Scheduling (when parameter)
| Value | Meaning |
|-------|---------|
| `today` | Show in Today list |
| `tomorrow` | Schedule for tomorrow |
| `evening` | Show in Today's Evening section |
| `anytime` | Available anytime (default) |
| `someday` | Defer to Someday list |
| `2026-01-20` | Specific date |

### Due Dates vs Scheduling
- `when`: When you want to work on it (activation date)
- `due_date`: Hard deadline (shown with warning if approaching)

## Common Workflows

### 1. Daily Review
```
get_today        → See today's tasks
get_inbox        → Process new items
complete_todo    → Mark done items
```

### 2. Weekly Review
```
get_projects     → Review all projects
get_someday      → Review deferred items
get_upcoming     → Check scheduled tasks
```

### 3. Quick Capture
```
add_todo(name: "...", project: "")  → Add to Inbox
show_quick_entry                     → Open Things Quick Entry
```

### 4. Project Planning
```
add_project(name: "New Project", area: "Work")
add_todo(name: "Task 1", project: "New Project")
add_todo(name: "Task 2", project: "New Project")
add_checklist_items(id: "task-id", items: ["Step 1", "Step 2"])
```

### 5. Batch Operations
For efficiency with multiple tasks:
```
create_todos_batch    → Create multiple tasks at once
complete_todos_batch  → Complete multiple tasks
move_todos_batch      → Move multiple tasks
update_todos_batch    → Update multiple tasks
delete_todos_batch    → Delete multiple tasks
```

## Tool Categories

### Reading (Safe)
- `get_*` - Retrieve lists/items
- `search_todos` - Find tasks by query
- `get_todos_in_project` - Tasks in specific project
- `get_projects_in_area` - Projects in specific area

### Writing (Modifying)
- `add_*` - Create new items
- `update_*` - Modify existing items
- `complete_*` - Mark as done
- `delete_*` - Move to trash
- `move_*` - Change location
- `cancel_*` - Mark as canceled

### UI Control
- `show_*` - Open Things 3 to specific view
- `edit_*` - Open item in edit mode

## Best Practices

1. **Use batch operations** for multiple items (more efficient)
2. **Always specify project** parameter (even if empty string)
3. **Use search** before creating duplicates
4. **Process Inbox regularly** - keep it empty
5. **Set due dates sparingly** - only for real deadlines
