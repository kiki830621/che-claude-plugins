# CLAUDE.md

This file provides guidance to Claude Code when working with this plugin marketplace.

## 專案概覽

這是 Che Cheng 的個人 Claude Code Plugin Marketplace，專注於學術研究與生產力工具。

## 目錄結構

```
che-claude-plugins/
├── .claude-plugin/
│   └── marketplace.json      # Marketplace 元數據
├── plugins/
│   ├── archive-mail/         # Apple Mail 歸檔工具
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── commands/
│   │   │   └── archive-mail.md
│   │   └── README.md
│   └── r-shiny-debugger/     # R Shiny Debug 工具
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/
│       │   └── shiny-debug.md
│       └── README.md
└── README.md
```

## Plugins 說明

### archive-mail (v2.0.0)

**用途**: 歸檔 Apple Mail 郵件到 Markdown 檔案

**依賴**:
- `apple-mail` MCP server（工具前綴：`mcp__apple-mail__*`）

**使用**:
```bash
/archive-mail d06227105@ntu.edu.tw
/archive-mail d06227105@ntu.edu.tw communication/emails
```

**功能**:
- 搜尋指定聯絡人的收/發郵件
- 轉換為 Markdown 格式，含元數據表格
- Message-ID 去重，避免重複歸檔
- AI 自動提取重點摘要和待辦事項

### r-shiny-debugger (v1.0.0)

**用途**: 功能測試導向的 R Shiny App Debug 工具

**依賴**:
- `agent-browser` CLI 工具（全域安裝）
- R 和 Rscript

**使用**:
```bash
/shiny-debug                           # 互動模式
/shiny-debug 上傳 CSV 後圖表會更新      # 口頭描述測試
/shiny-debug --file                    # 執行 .shiny-tests.yaml
/shiny-debug --file test_upload        # 執行指定測試案例
```

**功能**:
- 自動啟動 Shiny app 並監控 R console
- 使用 agent-browser 進行前端互動
- 支援口頭描述的功能測試
- 支援 `.shiny-tests.yaml` 定義測試案例
- 同時觀察前端 UI 變化和後端 R 輸出

### che-archive-lines (v1.0.0)

**用途**: 自動化 LINE macOS 聊天記錄的歸檔

**依賴**:
- `cliclick` CLI 工具（`brew install cliclick`）
- LINE macOS 已安裝並登入
- Accessibility 權限

**使用**:
```bash
/archive-lines calibrate   # 第一次使用：校準按鈕位置
/archive-lines save        # 自動儲存當前聊天
/archive-lines test        # 測試點擊位置
```

**功能**:
- 自動化 LINE 的「儲存聊天」功能
- 使用相對座標，視窗移動時自動調整
- 設定儲存在 `~/.config/che-archive-lines/config.json`

**技術說明**:
- LINE 使用 Qt 框架，不支援 macOS Accessibility API
- 使用 cliclick 進行座標點擊自動化

## MCP 依賴說明

### apple-mail MCP

**全域設定位置**: `~/.claude/settings.json`

**設定格式**:
```json
{
  "mcpServers": {
    "apple-mail": {
      "command": "path/to/apple-mail-mcp"
    }
  }
}
```

**工具命名規則**:
- MCP 工具前綴格式：`mcp__{server-key}__`
- 範例：`mcp__apple-mail__search_emails`

**在 plugin 中聲明依賴**:
```yaml
---
allowed-tools: mcp__apple-mail__*, Bash(mkdir:*), Read, Write, Glob
---
```

## 開發指南

### 新增 Plugin

1. 在 `plugins/` 下建立目錄
2. 建立 `.claude-plugin/plugin.json`
3. 建立 `commands/` 目錄和命令檔案
4. 更新 `marketplace.json` 註冊 plugin

### Plugin 結構範本

```
plugins/new-plugin/
├── .claude-plugin/
│   └── plugin.json           # 必須
├── commands/
│   └── command-name.md       # 至少一個命令
└── README.md                 # 建議
```

### plugin.json 範本

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "簡短說明",
  "author": { "name": "Che Cheng" },
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"]
}
```

### 命令檔案 Frontmatter

```yaml
---
description: 命令的簡短說明
argument-hint: <必填參數> [可選參數]
allowed-tools: Tool1, Tool2, mcp__server__*
---
```

## 安裝方式

```bash
# 添加 Marketplace
/plugin marketplace add kiki830621/che-claude-plugins

# 安裝 Plugin
/plugin install archive-mail@kiki830621/che-claude-plugins
/plugin install r-shiny-debugger@kiki830621/che-claude-plugins
```

---

最後更新: 2026-01-13
維護者: Che Cheng
