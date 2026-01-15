# MCP Tools

MCP Server 開發工具集，整合連線診斷、功能除錯、完整測試三大功能。

## Commands

| Command | 用途 | 使用時機 |
|---------|------|----------|
| `/mcp-tools:diagnose` | 連線診斷 | Server 無法連線時 |
| `/mcp-tools:debug` | 功能除錯 | 有 bug、錯誤時 |
| `/mcp-tools:test` | 完整測試 | 開發完成後、CI |

## 使用流程

```
MCP Server 有問題？
        │
        ▼
┌───────────────────┐
│ /mcp-tools:diagnose │  ← 先確認連線正常
└─────────┬─────────┘
          │
    連線正常？
    │     │
   Yes    No → 修復連線問題
    │
    ▼
┌───────────────────┐
│ /mcp-tools:debug  │  ← 診斷功能問題
└─────────┬─────────┘
          │
    問題解決？
    │     │
   Yes    No → 根據報告修復
    │
    ▼
┌───────────────────┐
│ /mcp-tools:test   │  ← 驗證所有功能
└───────────────────┘
```

## Commands 詳情

### `/mcp-tools:diagnose <server-name>`

**連線診斷**：確認 MCP Server 基本連線正常。

```bash
/mcp-tools:diagnose che-ical-mcp
```

功能：
- 檢查 `claude mcp list` 連線狀態
- 測試基本 tool 呼叫
- 輸出連線診斷報告

### `/mcp-tools:debug <server-name> [error-message]`

**功能除錯**：深入診斷功能問題。

```bash
/mcp-tools:debug che-ical-mcp
/mcp-tools:debug che-things-mcp "access denied"
```

功能：
- 快速診斷（3 個讀取測試）
- 錯誤訊息分析
- 框架特定除錯（AppleScript / EventKit）
- 權限問題修復指引

### `/mcp-tools:test <server-name>`

**完整測試**：驗證所有 tools 正常運作。

```bash
/mcp-tools:test che-ical-mcp
```

功能：
- 自動發現所有 tools
- 分類測試（讀取 / 搜尋 / 建立修改刪除）
- 生命週期測試（無副作用）
- 覆蓋率報告

## 支援的框架

| 框架 | 適用 MCP | 特殊除錯 |
|------|----------|----------|
| AppleScript | che-things-mcp, che-apple-mail-mcp | Dictionary 分析、唯讀屬性 |
| EventKit | che-ical-mcp | 隱私權限（Calendars/Reminders）|
| 其他 Swift | - | Package.swift 分析 |

## 權限問題快速修復

EventKit MCP 最常見問題是權限：

```bash
# 開啟系統設定
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Reminders"
```

**重要**：要授權的是 **IDE**（Cursor/VS Code/Terminal），不是 MCP binary！

## 測試資料命名規則

| 類型 | 前綴 |
|------|------|
| Event | `MCP_DEBUG_TEST_EVENT` |
| Reminder | `MCP_DEBUG_TEST_REMINDER` |
| Calendar | `MCP_DEBUG_TEST_CALENDAR` |
| Todo | `MCP_DEBUG_TEST_TODO` |
| Project | `MCP_DEBUG_TEST_PROJECT` |
