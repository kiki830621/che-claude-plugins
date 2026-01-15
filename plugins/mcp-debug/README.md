# MCP Debug

MCP Server 除錯與測試工具，支援 AppleScript 和 EventKit 框架。

## 功能概覽

| Command | 用途 | 使用時機 |
|---------|------|----------|
| `/mcp-debug:mcp-debug` | 問題診斷 | 有 bug、錯誤時 |
| `/mcp-debug:mcp-test` | 完整測試 | 開發完成後、CI |

## Commands

### `/mcp-debug:mcp-debug <server-name> [error-message]`

**問題診斷流程**：當 MCP Server 有問題時使用。

特色：
- 快速診斷（連線檢查 + 3 個讀取測試）
- 錯誤訊息分析（自動判斷問題類型）
- 框架特定除錯（AppleScript / EventKit / 其他）
- 權限問題修復指引
- 診斷報告生成

```bash
# 範例
/mcp-debug:mcp-debug che-ical-mcp
/mcp-debug:mcp-debug che-things-mcp "access denied"
```

### `/mcp-debug:mcp-test <server-name>`

**完整功能測試**：驗證所有 tools 正常運作。

特色：
- 自動發現所有 tools（從 Server.swift）
- 分類測試（讀取 / 搜尋 / 建立修改刪除）
- 生命週期測試（create → update → delete）
- 測試資料自動清理（`MCP_DEBUG_TEST_` 前綴）
- 覆蓋率報告

```bash
# 範例
/mcp-debug:mcp-test che-ical-mcp
/mcp-debug:mcp-test che-things-mcp
```

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

## 相關工具

- **mcp-diagnose**: MCP Server 連線診斷（純連線問題）
- **mcp-debug**: 功能診斷 + 完整測試（本 Plugin）
