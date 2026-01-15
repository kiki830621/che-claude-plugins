# Che's Claude Code Plugins

個人 Claude Code Plugin Marketplace，專注於學術研究與生產力工具。

## 安裝

```bash
# 添加 Marketplace
/plugin marketplace add kiki830621/che-claude-plugins

# 安裝 Plugin
/plugin install archive-mail@kiki830621/che-claude-plugins
/plugin install r-shiny-debugger@kiki830621/che-claude-plugins
```

## Plugins

| Plugin | 說明 | 依賴 |
|--------|------|------|
| **archive-mail** | 歸檔 Apple Mail 郵件到 Markdown | apple-mail MCP |
| **r-shiny-debugger** | R Shiny App 功能測試 | agent-browser |

### archive-mail

```bash
/archive-mail d06227105@ntu.edu.tw
/archive-mail d06227105@ntu.edu.tw communication/emails
```

### r-shiny-debugger

```bash
/shiny-debug
/shiny-debug 上傳 CSV 後圖表會更新
```

## 目錄結構

```
che-claude-plugins/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── archive-mail/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── commands/archive-mail.md
│   │   └── README.md
│   └── r-shiny-debugger/
│       ├── .claude-plugin/plugin.json
│       ├── commands/shiny-debug.md
│       └── README.md
└── README.md
```

## License

MIT
