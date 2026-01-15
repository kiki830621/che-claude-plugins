---
description: MCP Server 除錯流程（支援多種框架）
argument-hint: <mcp-server-name> [specific-tool]
allowed-tools: Bash(sdef:*), Bash(osascript:*), Bash(claude mcp:*), Bash(pkill:*), Bash(swift:*), Bash(tccutil:*), Bash(open:*), Read, Write, Grep, Glob
---

# MCP Debug - 通用除錯流程

對 MCP Server 進行系統化除錯，支援不同的底層框架。

## 參數

- `$1` = MCP Server 名稱（如 `che-things-mcp`、`che-ical-mcp`）
- `$2` = 可選的特定 tool 名稱（用於測試特定功能）

---

## Phase 0: 識別框架類型

**首先判斷 MCP Server 使用的底層框架**：

### Step 0: 找到 MCP Server 原始碼

```bash
# 常見位置
ls -la ~/Library/CloudStorage/Dropbox/che_workspace/projects/mcp/$1/
# 或
ls -la ~/projects/mcp/$1/
```

### Step 1: 判斷框架類型

| 特徵 | 框架類型 | 除錯方式 |
|------|----------|----------|
| `import EventKit` | **EventKit** | 讀 Swift 程式碼 |
| `tell application` | **AppleScript** | 用 `sdef` 匯出 Dictionary |
| `NSAppleScript` | **AppleScript (via Swift)** | 兩者都要看 |
| `import Contacts` | **Contacts Framework** | 讀 Swift 程式碼 |
| `import CoreData` | **CoreData** | 讀 Swift 程式碼 |
| HTTP/REST calls | **Web API** | 讀 API 文檔 |

**判斷命令**：
```bash
# 檢查 Swift imports
grep -r "^import" $1/Sources/ 2>/dev/null | head -20

# 檢查是否有 AppleScript
grep -r "tell application\|NSAppleScript" $1/Sources/ 2>/dev/null
```

---

## 框架 A: AppleScript 除錯流程

適用於：`che-things-mcp`、`che-apple-mail-mcp` 等使用 AppleScript 的 MCP

### A1: 匯出 AppleScript Dictionary

```bash
sdef /Applications/<AppName>.app > /tmp/<AppName>-dictionary.xml
```

| MCP Server | App | 匯出命令 |
|------------|-----|----------|
| che-things-mcp | Things3 | `sdef /Applications/Things3.app` |
| che-apple-mail-mcp | Mail | `sdef /Applications/Mail.app` |

### A2: 分析 Dictionary

```bash
# Classes
grep 'class name=' /tmp/<AppName>-dictionary.xml

# 唯讀屬性（不能直接 set）
grep 'access="r"' /tmp/<AppName>-dictionary.xml

# 可用命令
grep 'command name=' /tmp/<AppName>-dictionary.xml
```

### A3: 單元測試（AppleScript 層）

**測試模板**：
```applescript
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

**執行測試**：
```bash
osascript -e 'tell application "Things3" to get name of every to do'
```

### A4: 常見 AppleScript 錯誤

| 錯誤訊息 | 原因 | 解決方案 |
|----------|------|----------|
| `Can't set property` | 屬性唯讀 | 使用替代命令 |
| `AppleEvent handler failed` | 語法錯誤 | 檢查 Dictionary |
| `Can't get list "Inbox"` | 使用了 localized 名稱 | 使用 internal ID |

---

## 框架 B: EventKit 除錯流程

適用於：`che-ical-mcp` 等使用 EventKit 的 MCP

### B1: 讀取程式碼結構

```bash
# 列出所有 Swift 檔案
ls -la $1/Sources/**/*.swift

# 查看主要 Manager 類別
cat $1/Sources/*/EventKitManager.swift
```

### B2: 分析 EventKit 功能

檢查程式碼中的關鍵模式：

| 模式 | 功能 | 位置 |
|------|------|------|
| `EKEventStore` | 存取行事曆資料 | Manager 初始化 |
| `requestAccess` | 權限請求 | 首次使用時 |
| `predicateForEvents` | 查詢事件 | list/search 功能 |
| `save(_:span:)` | 儲存變更 | create/update 功能 |

### B3: 權限除錯（重要！）

EventKit 需要系統權限，這是最常見的問題來源。

#### Step 1: 識別權限錯誤

如果看到這類錯誤：
```
Error: Calendars access denied...
Error: Reminders access denied...
```

#### Step 2: 開啟系統設定

```bash
# 開啟 Calendars 權限設定
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"

# 開啟 Reminders 權限設定
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Reminders"
```

#### Step 3: 找到正確的授權對象

**重要**：MCP Server 是由 IDE 啟動的子進程，所以要授權的是 **IDE**，不是 binary 本身！

| 你使用的工具 | 要授權的項目 |
|-------------|-------------|
| Cursor | **Cursor** |
| VS Code | **Code** |
| Terminal 直接執行 | **Terminal** / **iTerm** |
| Claude Desktop | **Claude** |

#### Step 4: 如果列表中沒有看到任何項目

權限只有在「首次請求存取」時才會出現。用以下步驟強制觸發：

```bash
# 1. 重置權限
tccutil reset Calendars
tccutil reset Reminders

# 2. 用 AppleScript 觸發權限請求（會彈出對話框）
osascript -e 'tell application "Calendar" to get name of every calendar'
osascript -e 'tell application "Reminders" to get name of every list'

# 3. 再次開啟設定頁面，現在應該會看到項目了
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Reminders"
```

#### Step 5: 授權後重新測試

授權完成後，直接重新呼叫 MCP tool 測試，不需要重啟。

### B4: 常見 EventKit 錯誤

| 錯誤訊息 | 原因 | 解決方案 |
|----------|------|----------|
| `access denied` | 未授權 | 見上方 B3 權限除錯流程 |
| `Calendar not found` | 日曆名稱錯誤 | 用 `list_calendars` 確認 |
| `multiple calendars found` | 多個同名日曆 | 加上 `calendar_source` 參數 |

#### 權限機制說明

```
┌─────────────────────────────────────────────────────────┐
│  AppleScript (osascript)  vs  EventKit Framework        │
├─────────────────────────────────────────────────────────┤
│  osascript 成功          │  MCP (EventKit) 失敗         │
│  ↓                       │  ↓                           │
│  Apple Events 權限       │  Privacy - Calendars/        │
│  (Automation)            │  Reminders 權限              │
├─────────────────────────────────────────────────────────┤
│  這是兩個不同的權限機制！                                │
│  AppleScript 能用不代表 EventKit 也能用                 │
└─────────────────────────────────────────────────────────┘
```

---

## 框架 C: 其他 Swift Framework

適用於：Contacts、CoreData、其他原生框架

### C1: 讀取程式碼

```bash
# 找出主要的 Manager/Service 類別
grep -r "class.*Manager\|class.*Service" $1/Sources/
```

### C2: 分析依賴

```bash
# Package.swift 看依賴
cat $1/Package.swift
```

---

## Phase 2: MCP 層整合測試（通用）

**不論底層框架，MCP tools 測試方式相同**：

### Step 1: 檢查連線狀態

```bash
claude mcp list 2>&1 | grep -A1 "$1"
```

### Step 2: 提取所有 Tools 定義

從 `Server.swift` 讀取 `defineTools()` 方法，提取所有 tool 名稱和參數：

```bash
# 提取 tool 定義區塊
grep -A 50 "func defineTools" $1/Sources/*/Server.swift | head -100
```

**產生 Tool 清單**：

讀取程式碼後，產生一個完整的 tool 清單表格：

```markdown
## Tool 清單（自動產生）

| # | Tool 名稱 | 類型 | 必要參數 | 測試狀態 |
|---|-----------|------|----------|----------|
| 1 | list_xxx | 讀取 | 無 | ⏳ 待測 |
| 2 | search_xxx | 搜尋 | query | ⏳ 待測 |
| 3 | create_xxx | 寫入 | title, ... | ⏳ 待測 |
...
```

**Tool 分類規則**：
- `list_*`、`get_*` → 讀取類（安全，優先測試）
- `search_*`、`find_*` → 搜尋類（安全）
- `create_*`、`add_*` → 建立類（會改資料）
- `update_*`、`edit_*` → 修改類（會改資料）
- `delete_*`、`remove_*` → 刪除類（危險，最後測試或跳過）

### Step 3: 執行單元測試（全部 Tools）

**逐一測試每個 tool**，依照以下順序：

#### 3.1 讀取類 Tools（先測）

對每個 `list_*` / `get_*` tool：
1. 呼叫 tool（無參數或最小參數）
2. 記錄結果：✅ 成功 / ❌ 失敗 + 錯誤訊息
3. 如果失敗，判斷是**權限問題**還是**參數問題**

#### 3.2 搜尋類 Tools

對每個 `search_*` / `find_*` tool：
1. 準備測試參數（如 `keyword: "test"`）
2. 呼叫 tool
3. 記錄結果

#### 3.3 建立類 Tools（小心測試）

對每個 `create_*` / `add_*` tool：
1. 準備最小必要參數
2. **詢問用戶是否要測試**（會產生真實資料）
3. 如果測試，記得之後清理測試資料

#### 3.4 修改/刪除類 Tools（通常跳過）

- 這類 tools 需要真實 ID，且會改變資料
- 通常在單元測試階段跳過，標記為「需手動測試」

### Step 4: 更新測試狀態

測試完成後，更新 Tool 清單的測試狀態欄位：

```markdown
| # | Tool 名稱 | 類型 | 必要參數 | 測試狀態 |
|---|-----------|------|----------|----------|
| 1 | list_calendars | 讀取 | 無 | ✅ PASS |
| 2 | list_reminders | 讀取 | 無 | ❌ FAIL: access denied |
| 3 | search_events | 搜尋 | keyword | ✅ PASS |
| 4 | create_event | 建立 | title, start, end | ⏭️ 跳過 |
...
```

**失敗處理**：
- 如果讀取類 tools 失敗 → 回到 **B3 權限除錯**
- 如果搜尋類 tools 失敗 → 檢查參數格式
- 如果建立類 tools 失敗 → 檢查必要參數是否完整

---

## Phase 3: 診斷報告

產生診斷報告：

```markdown
# MCP Debug Report: <server-name>
Generated: <timestamp>

## 框架識別
- 類型: AppleScript / EventKit / Other
- 主要檔案: <path>

## 連線狀態
- Server: ✅/❌ Connected

## API 分析
（根據框架類型填寫）

## 測試結果
| Tool | 結果 | 錯誤訊息 |
|------|------|----------|
| ... | PASS/FAIL | ... |

## 發現的問題
1. ...

## 下一步
- [ ] ...
```

---

## Phase 4: 修復後驗證

### 重新建置與重啟

```bash
# 重新建置
cd $1
swift build -c release

# 重啟 server（Claude Code 會自動重連）
pkill -f <BinaryName>

# 驗證重連
claude mcp list 2>&1 | grep -A1 "$1"
```

---

## 快速參考

### MCP Server 對應表

| MCP Server | 框架 | App/API | Binary |
|------------|------|---------|--------|
| che-things-mcp | AppleScript | Things3 | CheThingsMCP |
| che-apple-mail-mcp | AppleScript | Mail | CheAppleMailMCP |
| che-ical-mcp | **EventKit** | Calendar/Reminders | CheICalMCP |

### Things 3 List IDs（AppleScript 專用）

| 清單 | ID |
|------|-----|
| Inbox | `TMInboxListSource` |
| Today | `TMTodayListSource` |
| Upcoming | `TMCalendarListSource` |
| Anytime | `TMNextListSource` |
| Someday | `TMSomedayListSource` |
| Logbook | `TMLogbookListSource` |
