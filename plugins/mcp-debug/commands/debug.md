---
description: MCP Server AppleScript 除錯流程
argument-hint: <app-name> [tool-name]
allowed-tools: Bash(sdef:*), Bash(osascript:*), Bash(claude mcp:*), Bash(pkill:*), Read, Grep, Glob
---

# MCP Debug - AppleScript 除錯流程

對 MCP Server 的 AppleScript 整合進行系統化除錯。

## 參數

- `$1` = App 名稱（如 `Things3`、`Mail`、`Reminders`）
- `$2` = 可選的 MCP tool 名稱（用於測試特定功能）

## 執行步驟

### Step 1: 匯出 AppleScript Dictionary

使用 `sdef` 匯出目標 App 的 AppleScript Dictionary：

```bash
sdef /Applications/$1.app > /tmp/$1-dictionary.xml
```

如果 App 名稱有空格，嘗試：
```bash
sdef "/Applications/$1.app" > /tmp/$1-dictionary.xml
```

### Step 2: 分析 Dictionary

讀取匯出的 XML 並分析：

1. **找出所有 class**：
   ```bash
   grep 'class name=' /tmp/$1-dictionary.xml
   ```

2. **找出唯讀屬性**（這些不能直接設定）：
   ```bash
   grep 'access="r"' /tmp/$1-dictionary.xml
   ```

3. **找出可用的 command**：
   ```bash
   grep 'command name=' /tmp/$1-dictionary.xml
   ```

### Step 3: 常見問題檢查

根據 Dictionary 分析，檢查以下常見問題：

| 錯誤類型 | 可能原因 | 解決方案 |
|----------|----------|----------|
| `Can't set property` | 屬性是唯讀 (`access="r"`) | 使用替代 command |
| `AppleEvent handler failed` | `make` 命令語法錯誤 | 先建立再設定屬性 |
| `Can't get list` | 使用了 localized 名稱 | 使用 `list id "..."` |
| 日期解析失敗 | Locale 問題 | 使用 ISO 格式 `yyyy-MM-dd` |

### Step 4: 測試 MCP Tool（如果提供 $2）

如果提供了 tool 名稱，執行測試：

```bash
claude mcp call <server-name> $2 '{}'
```

### Step 5: 輸出診斷報告

提供以下資訊：
1. App 的 AppleScript 支援狀態
2. 發現的唯讀屬性列表
3. 可用的 command 列表
4. 建議的修復方向

## 快速參考

### 常用 App 路徑

| App | 路徑 |
|-----|------|
| Things 3 | `/Applications/Things3.app` |
| Mail | `/Applications/Mail.app` |
| Reminders | `/Applications/Reminders.app` |
| Calendar | `/Applications/Calendar.app` |
| Notes | `/Applications/Notes.app` |

### Things 3 List IDs

| 清單 | ID |
|------|-----|
| Inbox | `TMInboxListSource` |
| Today | `TMTodayListSource` |
| Upcoming | `TMCalendarListSource` |
| Anytime | `TMNextListSource` |
| Someday | `TMSomedayListSource` |
| Logbook | `TMLogbookListSource` |

---

## MCP Server 重啟

當修復 bug 並重新建置 MCP Server 後，需要重啟才能生效。

### Step 6: 重啟 MCP Server（修復後）

```bash
# 終止 MCP server process，Claude Code 會自動重連
pkill -f <binary-name>

# 驗證重連
claude mcp list 2>&1 | grep -A1 "<server-name>"
```

### 常用重啟命令

| MCP Server | 重啟命令 |
|------------|----------|
| Things 3 | `pkill -f CheThingsMCP` |
| Apple Mail | `pkill -f CheAppleMailMCP` |

### 部署腳本範例

```bash
#!/bin/bash
# deploy.sh
swift build -c release
cp .build/release/BinaryName ~/bin/
pkill -f BinaryName || true
echo "✅ 部署完成"
```
