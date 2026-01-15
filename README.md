# Che's Claude Code Plugins

個人 Claude Code Plugin Marketplace，專注於學術研究與生產力工具。

## 安裝

```bash
# 添加 Marketplace
/plugin marketplace add kiki830621/che-claude-plugins

# 安裝 Plugin
/plugin install mcp-tools@kiki830621/che-claude-plugins
/plugin install archive-mail@kiki830621/che-claude-plugins
```

## Plugins

| Plugin | 說明 | 版本 |
|--------|------|------|
| **mcp-tools** | MCP Server 開發工具集（診斷、除錯、測試） | v1.0.0 |
| **archive-mail** | 歸檔 Apple Mail 郵件到 Markdown | - |
| **r-shiny-debugger** | R Shiny App 功能測試 | - |
| **claude-config-guide** | Claude Code 設定查詢助手 | - |

---

### mcp-tools

MCP Server 開發必備工具，提供完整的除錯與測試流程。

```bash
/mcp-tools:diagnose che-ical-mcp   # 連線診斷
/mcp-tools:debug che-ical-mcp      # 功能除錯
/mcp-tools:test che-ical-mcp       # 完整測試
```

| Command | 用途 |
|---------|------|
| `diagnose` | 確認 MCP Server 連線正常 |
| `debug` | 診斷功能問題（權限、框架特定） |
| `test` | 驗證所有 tools 正常運作 |

---

### archive-mail

歸檔特定聯絡人的 Apple Mail 郵件到 Markdown 檔案。

```bash
/archive-mail d06227105@ntu.edu.tw
/archive-mail d06227105@ntu.edu.tw communication/emails
```

---

### r-shiny-debugger

整合前端 (agent-browser) 與後端 (R console) 的 R Shiny App 功能測試。

```bash
/shiny-debug
/shiny-debug 上傳 CSV 後圖表會更新
```

---

### claude-config-guide

Claude Code 設定查詢助手，協助查找 MCP、settings、hooks 等設定。

```bash
/claude-config-guide MCP 設定在哪裡
```

## License

MIT
