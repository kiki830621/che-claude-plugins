# MCP Diagnose Plugin

診斷 MCP Server 連線問題的 Claude Code Plugin。

## 功能

- 4 步驟自動診斷：Binary → Initialize → Tools/List → Tools/Call
- 決策樹分析失敗原因
- 提供修復建議和參考文檔

## 使用方式

```
/mcp-diagnose /path/to/mcp-server
```

## 診斷步驟

| 步驟 | 測試內容 | 常見問題 |
|------|---------|---------|
| 1 | Binary Check | 權限、架構、路徑 |
| 2 | Initialize | Server 啟動問題 |
| 3 | Tools List | Handler 註冊問題 |
| 4 | Tools Call | Event Loop 阻塞、效能 |

## 相關文檔

- [MCP Debug 完整指南](../../mcp/docs/MCP_DEBUG_GUIDE.md)
- [AppleScript 本地化開發規範](../../mcp/docs/APPLESCRIPT_LOCALIZATION.md)

## 版本

- v1.0.0 - 初始版本
