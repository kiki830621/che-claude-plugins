# MCP Test

MCP Server 測試與除錯方法論 Skill，特別適用於使用 AppleScript 整合的 MCP Server。

## 功能

- 系統化的 MCP Server 除錯流程
- AppleScript Dictionary 分析方法
- 常見陷阱和解決方案
- Swift 實作建議

## 觸發條件

當對話涉及以下內容時自動載入：
- MCP Server 開發或除錯
- AppleScript 錯誤
- `AppleEvent handler failed` 錯誤
- `sdef` 命令

## 核心方法

1. **匯出 Dictionary** - 使用 `sdef` 獲取權威 API 文檔
2. **分析屬性** - 檢查 `access="r"` vs `access="rw"`
3. **識別陷阱** - 唯讀屬性、make 命令限制、locale 問題
4. **測試驗證** - 使用 `claude mcp call` 驗證修復

## 使用範例

```bash
# 匯出 Things 3 的 AppleScript Dictionary
sdef /Applications/Things3.app > things3.xml

# 查看特定 class 定義
sdef /Applications/Things3.app | grep -A 50 'class name="to do"'

# 測試 MCP tool
claude mcp call che-things-mcp add_todo '{"name": "Test"}'
```

## 相關工具

- **mcp-diagnose**: MCP Server 連線診斷（/mcp-diagnose）
- **mcp-test**: 功能測試與除錯方法論（本 Skill）
