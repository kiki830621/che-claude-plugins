---
name: mcp-test
description: |
  MCP Server 測試與除錯方法論。當開發或除錯 MCP Server 時載入。
  特別適用於使用 AppleScript 的 MCP Server（Things 3、Apple Mail、Reminders 等）。
  觸發關鍵字：MCP debug, AppleScript error, AppleEvent failed, sdef
allowed-tools: Bash, Read, Grep, Glob
---

# MCP Test - MCP Server 測試與除錯

系統化測試和除錯 MCP Server，特別是與 macOS 原生應用整合的 AppleScript 場景。

## 適用情境

- 開發 MCP Server 與 macOS App 整合（Things 3、Apple Mail、Reminders 等）
- AppleScript 命令執行失敗
- `AppleEvent handler failed` 錯誤
- 屬性設定失敗（唯讀屬性）
- 日期/清單名稱 locale 問題

## 核心原則

### 1. 權威來源優先

**永遠使用 `sdef` 匯出 AppleScript Dictionary 作為唯一參考。**

不要猜測 AppleScript 語法。每個 macOS App 的 AppleScript API 都定義在其 Dictionary 中。

```bash
# 匯出完整 Dictionary
sdef /Applications/Things3.app > things3-dictionary.xml

# 快速查看特定 class
sdef /Applications/Things3.app | grep -A 50 'class name="to do"'

# 快速查看特定 command
sdef /Applications/Things3.app | grep -A 20 'command name="schedule"'
```

### 2. 檢查屬性存取等級

在 Dictionary 中，每個 property 都有 `access` 屬性：

- `access="r"` = **唯讀**，需使用替代命令
- `access="rw"` = 可讀寫

```xml
<!-- 例：activation date 是唯讀 -->
<property name="activation date" type="date" access="r"/>

<!-- 必須使用 schedule 命令代替 -->
<command name="schedule" code="THGSschd">
    <direct-parameter type="specifier"/>
    <parameter name="for" type="date" optional="no"/>
</command>
```

### 3. 測試驅動修復

1. **先確認問題** - 執行 MCP tool，記錄錯誤訊息
2. **查 Dictionary** - 用 `sdef` 匯出並分析
3. **修改程式碼** - 根據正確語法修改
4. **驗證修復** - 再次執行 MCP tool 確認

---

## 除錯流程

### Step 1: 匯出 AppleScript Dictionary

```bash
# 匯出目標 App 的 Dictionary
sdef /Applications/AppName.app > app-dictionary.xml

# 或直接在 Script Editor 中查看
open -a "Script Editor"
# 然後 File > Open Dictionary > 選擇 App
```

### Step 2: 定位失敗的操作

從錯誤訊息中找出：
- 哪個 class 或 property 出問題
- 哪個 command 執行失敗

常見錯誤訊息對應：
| 錯誤訊息 | 可能原因 |
|----------|----------|
| `Can't get property` | 屬性名稱錯誤或唯讀 |
| `Can't set property` | 屬性是唯讀 |
| `AppleEvent handler failed` | 命令語法錯誤 |
| `Can't make ... into type` | 類型不匹配 |

### Step 3: 分析 Dictionary

在匯出的 XML 中搜尋：

```bash
# 搜尋 class 定義
grep -A 50 'class name="to do"' app-dictionary.xml

# 搜尋 command 定義
grep -A 20 'command name="schedule"' app-dictionary.xml

# 搜尋 property
grep 'property name="activation date"' app-dictionary.xml
```

關鍵檢查項目：
- 屬性的 `access` 是 `r` 還是 `rw`
- 命令的必要參數（`optional="no"`）
- 命令的 direct-parameter 類型

### Step 4: 修復並測試

根據 Dictionary 修改程式碼，然後測試：

```bash
# 使用 claude mcp call 測試
claude mcp call <server-name> <tool-name> '{"param": "value"}'
```

---

## 常見陷阱

### 陷阱 1: 唯讀屬性

**錯誤做法：**
```applescript
set activation date of myTodo to (current date)
-- 失敗！activation date 是唯讀
```

**正確做法：**
```applescript
schedule myTodo for (current date)
-- 使用 schedule 命令代替
```

### 陷阱 2: make 命令的位置限制

許多 App 的 `make` 命令不支援 `in list` 或 `in project` 語法。

**錯誤做法：**
```applescript
make new to do with properties {name:"Task"} in project "ProjectName"
-- 失敗！make 不支援 in project
```

**正確做法：**
```applescript
set newTodo to make new to do with properties {name:"Task"}
set project of newTodo to project "ProjectName"
-- 先建立，再設定屬性
```

### 陷阱 3: 日期格式（Locale 問題）

AppleScript 的日期解析依賴系統 locale。

**錯誤做法：**
```applescript
date "2026年1月15日"  -- 只在繁體中文系統有效
date "January 15, 2026"  -- 只在英文系統有效
```

**正確做法：**
```applescript
date "2026-01-15"  -- ISO 格式，locale 獨立
```

**Swift 實作建議：**
```swift
// 解析各種輸入格式
func parseDate(_ string: String) -> Date? {
    let formatters = [
        "yyyy-MM-dd",      // ISO
        "yyyy/MM/dd",      // 斜線
        "yyyy年M月d日"      // 中文
    ]
    // 嘗試每種格式...
}

// 輸出統一使用 ISO
formatter.dateFormat = "yyyy-MM-dd"
```

### 陷阱 4: 清單名稱（Locale 問題）

內建清單名稱會因語言設定而不同。

**錯誤做法：**
```applescript
list "Today"  -- 只在英文系統有效
list "今天"   -- 只在中文系統有效
```

**正確做法：**
```applescript
list id "TMTodayListSource"  -- 內部 ID，locale 獨立
```

---

## 快速參考

### sdef 常用命令

```bash
# 匯出完整 Dictionary
sdef /Applications/Things3.app > things3.xml
sdef /Applications/Mail.app > mail.xml
sdef /Applications/Reminders.app > reminders.xml

# 查看特定 class
sdef /Applications/Things3.app | grep -A 50 'class name="to do"'

# 查看特定 command
sdef /Applications/Things3.app | grep -A 20 'command name="schedule"'

# 列出所有 list ID
osascript -e 'tell application "Things3" to get id of every list'
```

### Things 3 List IDs

| 清單名稱 | Internal ID |
|----------|-------------|
| Inbox | `TMInboxListSource` |
| Today | `TMTodayListSource` |
| Upcoming | `TMCalendarListSource` |
| Anytime | `TMNextListSource` |
| Someday | `TMSomedayListSource` |
| Logbook | `TMLogbookListSource` |

### Things 3 Status Values

| 狀態 | AppleScript 值 |
|------|---------------|
| 開放 | `open` |
| 已完成 | `completed` |
| 已取消 | `canceled` |

---

## Swift 實作建議

### 日期處理

```swift
private func parseDate(_ string: String) -> Date? {
    let formatters: [DateFormatter] = [
        { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f }(),
        { let f = DateFormatter(); f.dateFormat = "yyyy/MM/dd"; return f }(),
        {
            let f = DateFormatter()
            f.locale = Locale(identifier: "zh_TW")
            f.dateFormat = "yyyy年M月d日"
            return f
        }(),
    ]
    for formatter in formatters {
        if let date = formatter.date(from: string) {
            return date
        }
    }
    return nil
}

// 輸出給 AppleScript
private func formatForAppleScript(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return "date \"\(formatter.string(from: date))\""
}
```

### 字串跳脫

```swift
private func escapeForAppleScript(_ string: String) -> String {
    return string
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
}
```

### 非同步執行

```swift
func executeAppleScript(_ script: String) async throws -> String {
    return try await withCheckedThrowingContinuation { continuation in
        Task.detached {
            var error: NSDictionary?
            let appleScript = NSAppleScript(source: script)
            let result = appleScript?.executeAndReturnError(&error)

            if let error = error {
                continuation.resume(throwing: AppleScriptError(error))
            } else {
                continuation.resume(returning: result?.stringValue ?? "")
            }
        }
    }
}
```

---

## 相關資源

- [Things 3 AppleScript Reference](../../../che-things-mcp/docs/applescript-reference.md)
- [Apple Events Programming Guide](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/)
- [mcp-diagnose](/mcp-diagnose) - MCP Server 連線診斷工具
