---
description: MCP Server AppleScript 除錯流程（含測試生成）
argument-hint: <mcp-server-name> [specific-tool]
allowed-tools: Bash(sdef:*), Bash(osascript:*), Bash(claude mcp:*), Bash(pkill:*), Read, Write, Grep, Glob
---

# MCP Debug - AppleScript 除錯流程

對 MCP Server 的 AppleScript 整合進行系統化除錯，包含自動生成單元測試和整合測試。

## 參數

- `$1` = MCP Server 名稱（如 `che-things-mcp`、`che-apple-mail-mcp`）
- `$2` = 可選的特定 tool 名稱（用於測試特定功能）

## 執行流程

```
┌─────────────────────────────────────────────────────────────┐
│  Phase 1: 分析                                               │
│  ├─ Step 1: 檢查 MCP Server 連線                            │
│  ├─ Step 2: 匯出 AppleScript Dictionary                     │
│  └─ Step 3: 分析 API（classes, properties, commands）       │
├─────────────────────────────────────────────────────────────┤
│  Phase 2: 單元測試（AppleScript 層）                         │
│  ├─ Step 4: 產生 AppleScript 單元測試                       │
│  └─ Step 5: 執行單元測試並記錄結果                          │
├─────────────────────────────────────────────────────────────┤
│  Phase 3: 整合測試（MCP 層）                                 │
│  ├─ Step 6: 列出所有 MCP tools                              │
│  ├─ Step 7: 產生整合測試案例                                │
│  └─ Step 8: 執行整合測試並記錄結果                          │
├─────────────────────────────────────────────────────────────┤
│  Phase 4: 報告                                               │
│  └─ Step 9: 輸出診斷報告（含測試結果摘要）                  │
├─────────────────────────────────────────────────────────────┤
│  Phase 5: 修復後驗證                                         │
│  ├─ Step 10: 重啟 MCP Server                                │
│  └─ Step 11: 重新執行失敗的測試                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Phase 1: 分析

### Step 1: 檢查 MCP Server 連線

```bash
claude mcp list 2>&1 | grep -A1 "$1"
```

確認 server 顯示 `✓ Connected`。如果沒有，先用 `/mcp-diagnose` 診斷連線問題。

### Step 2: 匯出 AppleScript Dictionary

根據 MCP server 對應的 App 匯出 Dictionary：

| MCP Server | App | 匯出命令 |
|------------|-----|----------|
| che-things-mcp | Things3 | `sdef /Applications/Things3.app` |
| che-apple-mail-mcp | Mail | `sdef /Applications/Mail.app` |
| che-ical-mcp | Calendar | `sdef /Applications/Calendar.app` |

```bash
sdef /Applications/<AppName>.app > /tmp/<AppName>-dictionary.xml
```

### Step 3: 分析 API

從 Dictionary 提取關鍵資訊：

```bash
# Classes
grep 'class name=' /tmp/<AppName>-dictionary.xml

# 唯讀屬性（不能直接 set）
grep 'access="r"' /tmp/<AppName>-dictionary.xml

# 可用命令
grep 'command name=' /tmp/<AppName>-dictionary.xml
```

---

## Phase 2: 單元測試（AppleScript 層）

### Step 4: 產生 AppleScript 單元測試

根據 Dictionary 分析，為每個關鍵操作產生測試腳本。

**測試檔案位置**：`/tmp/mcp-debug-tests/unit/`

**測試模板**：

```applescript
-- test_<operation>.applescript
-- 測試目標：<描述>
-- 預期結果：<成功/失敗條件>

try
    tell application "<AppName>"
        -- 測試程式碼
        <test-code>
    end tell
    return "PASS: <描述>"
on error errMsg
    return "FAIL: " & errMsg
end try
```

**必要測試項目**：

| 測試類型 | 說明 | 範例 |
|----------|------|------|
| 讀取測試 | 讀取基本屬性 | `get name of every to do` |
| 建立測試 | 建立新物件 | `make new to do with properties {name:"Test"}` |
| 更新測試 | 修改可寫屬性 | `set notes of todo1 to "Updated"` |
| 刪除測試 | 刪除測試物件 | `delete todo1` |
| 命令測試 | 執行特殊命令 | `schedule todo1 for (current date)` |

### Step 5: 執行單元測試

```bash
# 執行所有單元測試
for f in /tmp/mcp-debug-tests/unit/*.applescript; do
    echo "=== $(basename $f) ==="
    osascript "$f"
done
```

**記錄結果到**：`/tmp/mcp-debug-tests/unit-results.txt`

---

## Phase 3: 整合測試（MCP 層）

### Step 6: 列出所有 MCP tools

```bash
claude mcp call $1 --list-tools 2>/dev/null || \
claude mcp list-tools $1 2>/dev/null || \
echo "手動查看 MCP server 的 tools"
```

### Step 7: 產生整合測試案例

**測試檔案位置**：`/tmp/mcp-debug-tests/integration/`

為每個 MCP tool 產生測試案例：

```json
// test_<tool-name>.json
{
  "tool": "<tool-name>",
  "description": "<測試描述>",
  "test_cases": [
    {
      "name": "basic",
      "input": { /* 最小必要參數 */ },
      "expected": "success"
    },
    {
      "name": "edge_case",
      "input": { /* 邊界條件 */ },
      "expected": "success|error"
    }
  ]
}
```

**必要測試的 tool 類型**：

| Tool 類型 | 測試重點 |
|-----------|----------|
| get_* | 能正確讀取資料 |
| add_* / create_* | 能建立新物件 |
| update_* | 能修改現有物件 |
| delete_* | 能刪除物件（小心！） |
| search_* | 能正確搜尋 |

### Step 8: 執行整合測試

```bash
# 執行單一 tool 測試
claude mcp call $1 <tool-name> '<json-input>'

# 批次執行（範例）
claude mcp call $1 get_today '{}'
claude mcp call $1 add_todo '{"name": "MCP Test Todo"}'
claude mcp call $1 search_todos '{"query": "MCP Test"}'
```

**記錄結果到**：`/tmp/mcp-debug-tests/integration-results.txt`

---

## Phase 4: 報告

### Step 9: 輸出診斷報告

產生完整的診斷報告，包含：

```markdown
# MCP Debug Report: <server-name>
Generated: <timestamp>

## 連線狀態
- Server: ✅/❌ Connected
- Binary: <path>

## AppleScript API 分析
- Classes: <count>
- Read-only properties: <list>
- Available commands: <list>

## 單元測試結果
| 測試 | 結果 | 錯誤訊息 |
|------|------|----------|
| test_read | PASS/FAIL | ... |
| test_create | PASS/FAIL | ... |

通過: X/Y (Z%)

## 整合測試結果
| Tool | 測試案例 | 結果 | 錯誤訊息 |
|------|----------|------|----------|
| get_today | basic | PASS/FAIL | ... |
| add_todo | basic | PASS/FAIL | ... |

通過: X/Y (Z%)

## 發現的問題
1. <問題描述>
   - 原因：<分析>
   - 建議：<修復方向>

## 下一步
- [ ] 修復問題 1
- [ ] 重新執行失敗的測試
```

---

## Phase 5: 修復後驗證

### Step 10: 重啟 MCP Server

```bash
# 重新建置（如果有修改程式碼）
swift build -c release

# 部署新版本
cp .build/release/<BinaryName> ~/bin/

# 重啟 server
pkill -f <BinaryName>

# 驗證重連
claude mcp list 2>&1 | grep -A1 "$1"
```

### Step 11: 重新執行失敗的測試

只重跑之前失敗的測試：

```bash
# 重跑失敗的單元測試
osascript /tmp/mcp-debug-tests/unit/test_<failed>.applescript

# 重跑失敗的整合測試
claude mcp call $1 <failed-tool> '<input>'
```

---

## 快速參考

### MCP Server 對應表

| MCP Server | App | Binary |
|------------|-----|--------|
| che-things-mcp | Things3 | CheThingsMCP |
| che-apple-mail-mcp | Mail | CheAppleMailMCP |
| che-ical-mcp | Calendar | CheICalMCP |

### 常見錯誤對照

| 錯誤訊息 | 原因 | 解決方案 |
|----------|------|----------|
| `Can't set property` | 屬性唯讀 | 使用替代命令 |
| `AppleEvent handler failed` | 語法錯誤 | 檢查 Dictionary |
| `Connection refused` | Server 未啟動 | `pkill` 後重連 |
| `Tool not found` | Tool 名稱錯誤 | 檢查 tool 列表 |

### Things 3 List IDs

| 清單 | ID |
|------|-----|
| Inbox | `TMInboxListSource` |
| Today | `TMTodayListSource` |
| Upcoming | `TMCalendarListSource` |
| Anytime | `TMNextListSource` |
| Someday | `TMSomedayListSource` |
| Logbook | `TMLogbookListSource` |
