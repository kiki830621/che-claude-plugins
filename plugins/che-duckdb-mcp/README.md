# che-duckdb-mcp

**DuckDB MCP Server** - 整合 DuckDB 文檔查詢與資料庫操作功能。

## 功能概覽

整合 14 個工具，分為兩大類：

### 文檔工具 (8 個)

| 工具 | 功能 |
|------|------|
| `search_docs` | 搜索 DuckDB 文檔 |
| `list_sections` | 列出文檔章節 |
| `get_section` | 取得章節內容 |
| `get_function_docs` | 查詢函數文檔 |
| `list_functions` | 列出所有函數 |
| `get_sql_syntax` | 查詢 SQL 語法 |
| `refresh_docs` | 強制更新文檔 |
| `get_doc_info` | 取得文檔資訊 |

### 資料庫工具 (6 個)

| 工具 | 功能 |
|------|------|
| `db_connect` | 連接資料庫（記憶體或檔案） |
| `db_query` | 執行 SELECT 查詢 |
| `db_execute` | 執行 DDL/DML 語句 |
| `db_list_tables` | 列出表格和視圖 |
| `db_describe` | 描述表格或查詢結構 |
| `db_info` | 取得資料庫資訊 |

## 安裝

### 1. 編譯 Binary

```bash
cd /path/to/che-duckdb-mcp
swift build -c release
cp .build/release/CheDuckDBMCP ~/bin/
```

### 2. 安裝 Plugin

```bash
claude /plugin che-duckdb-mcp
```

## 使用範例

### 文檔查詢

```
# 搜索文檔
"搜索 DuckDB 的 read_csv 函數"

# 查詢 SQL 語法
"DuckDB 的 COPY 語法是什麼？"
```

### 資料庫操作

```
# 連接記憶體資料庫
db_connect: {}

# 建立表格
db_execute: { "sql": "CREATE TABLE users (id INTEGER, name VARCHAR)" }

# 插入資料
db_execute: { "sql": "INSERT INTO users VALUES (1, 'Alice'), (2, 'Bob')" }

# 查詢資料
db_query: { "sql": "SELECT * FROM users", "format": "markdown" }
```

## 輸出格式

支援三種輸出格式：

- **json**: 結構化 JSON（預設）
- **markdown**: 表格格式（適合閱讀）
- **csv**: CSV 格式

## 技術細節

- **語言**: Swift
- **MCP SDK**: swift-sdk 0.10.0
- **DuckDB**: duckdb-swift
- **平台**: macOS 13.0+

## 安全考量

1. `db_query` 僅允許 SELECT/WITH/SHOW/DESCRIBE/EXPLAIN/PRAGMA
2. 預設限制返回 1000 行
3. 支援唯讀模式

## 版本

- **當前版本**: 1.0.0
- **專案位置**: `/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/mcp/che-duckdb-mcp`
