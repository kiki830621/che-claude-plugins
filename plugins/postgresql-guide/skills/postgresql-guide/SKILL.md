---
name: postgresql-guide
description: |
  Query PostgreSQL official documentation for accurate SQL syntax, configuration, and best practices.
  Use this skill proactively when the conversation involves:
  - PostgreSQL SQL syntax, commands, queries
  - Data types, functions, operators
  - Database configuration, postgresql.conf
  - Performance tuning, EXPLAIN, indexes
  - Backup, restore, replication
  - PL/pgSQL, stored procedures, triggers
allowed-tools: WebFetch, Read, Glob, Grep
---

# PostgreSQL Guide

This Skill queries official PostgreSQL documentation for accurate information.

## When to Use

When the user asks about or the conversation involves:
- PostgreSQL SQL syntax or commands
- Data types, functions, operators
- Database configuration (postgresql.conf, pg_hba.conf)
- Performance tuning, query optimization
- Backup, restore, high availability
- Extensions, procedural languages

## Execution Steps (IMPORTANT!)

**You MUST WebFetch official documentation - never answer from memory!**

### Step 1: Identify Question Category

| Category | Description |
|----------|-------------|
| SQL Commands | CREATE, SELECT, INSERT, UPDATE, DELETE, ALTER, etc. |
| Data Types | INTEGER, VARCHAR, JSON, ARRAY, etc. |
| Functions | String, Math, Date/Time, Aggregate, Window functions |
| Configuration | postgresql.conf, pg_hba.conf settings |
| Administration | Backup, Restore, Replication, Monitoring |
| Programming | PL/pgSQL, Triggers, Rules |

### Step 2: WebFetch the Corresponding Documentation

**Base URL:** `https://www.postgresql.org/docs/current/`

| Question Type | Documentation URL |
|---------------|-------------------|
| SQL Command Reference | https://www.postgresql.org/docs/current/sql-commands.html |
| Specific SQL Command | https://www.postgresql.org/docs/current/sql-{command}.html (e.g., sql-select.html) |
| Data Types | https://www.postgresql.org/docs/current/datatype.html |
| Functions & Operators | https://www.postgresql.org/docs/current/functions.html |
| String Functions | https://www.postgresql.org/docs/current/functions-string.html |
| Date/Time Functions | https://www.postgresql.org/docs/current/functions-datetime.html |
| Aggregate Functions | https://www.postgresql.org/docs/current/functions-aggregate.html |
| Window Functions | https://www.postgresql.org/docs/current/functions-window.html |
| JSON Functions | https://www.postgresql.org/docs/current/functions-json.html |
| Array Functions | https://www.postgresql.org/docs/current/functions-array.html |
| Indexes | https://www.postgresql.org/docs/current/indexes.html |
| Full Text Search | https://www.postgresql.org/docs/current/textsearch.html |
| Configuration | https://www.postgresql.org/docs/current/runtime-config.html |
| Authentication | https://www.postgresql.org/docs/current/auth-pg-hba-conf.html |
| Backup & Restore | https://www.postgresql.org/docs/current/backup.html |
| Replication | https://www.postgresql.org/docs/current/high-availability.html |
| PL/pgSQL | https://www.postgresql.org/docs/current/plpgsql.html |
| Triggers | https://www.postgresql.org/docs/current/triggers.html |
| Performance | https://www.postgresql.org/docs/current/performance-tips.html |
| EXPLAIN | https://www.postgresql.org/docs/current/using-explain.html |
| Error Codes | https://www.postgresql.org/docs/current/errcodes-appendix.html |

### Step 3: For Specific SQL Commands

SQL command documentation follows the pattern:
```
https://www.postgresql.org/docs/current/sql-{command}.html
```

**Examples:**
| Command | URL |
|---------|-----|
| SELECT | https://www.postgresql.org/docs/current/sql-select.html |
| CREATE TABLE | https://www.postgresql.org/docs/current/sql-createtable.html |
| CREATE INDEX | https://www.postgresql.org/docs/current/sql-createindex.html |
| ALTER TABLE | https://www.postgresql.org/docs/current/sql-altertable.html |
| INSERT | https://www.postgresql.org/docs/current/sql-insert.html |
| UPDATE | https://www.postgresql.org/docs/current/sql-update.html |
| DELETE | https://www.postgresql.org/docs/current/sql-delete.html |
| GRANT | https://www.postgresql.org/docs/current/sql-grant.html |
| COPY | https://www.postgresql.org/docs/current/sql-copy.html |
| VACUUM | https://www.postgresql.org/docs/current/sql-vacuum.html |
| EXPLAIN | https://www.postgresql.org/docs/current/sql-explain.html |

### Step 4: Parse and Respond

Extract relevant information from WebFetch results and answer the user directly.

## Common Questions Quick Reference

| Question | Fetch URL |
|----------|-----------|
| "How to create index?" | sql-createindex.html |
| "JSON operators?" | functions-json.html |
| "Window functions?" | functions-window.html |
| "How to backup?" | backup.html |
| "Connection config?" | runtime-config-connection.html |
| "pg_hba.conf syntax?" | auth-pg-hba-conf.html |
| "EXPLAIN ANALYZE?" | using-explain.html |
| "PL/pgSQL syntax?" | plpgsql.html |

## Important Reminder

**Never answer PostgreSQL questions from memory!**

PostgreSQL documentation is comprehensive and regularly updated. Always fetch the current documentation for:
- Exact syntax (especially for complex commands)
- Available options and parameters
- Version-specific features
- Best practices and warnings

## Why not use a sub-agent?

Sub-agent responses require paraphrasing, which may cause information loss.
**Fetch the docs yourself for more direct and accurate information.**
