# Che's Claude Code Plugins

[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Platform](https://img.shields.io/badge/Claude_Code-Plugin_Marketplace-blue)](https://code.claude.com/docs/en/discover-plugins)

個人 Claude Code Plugin Marketplace，專注於學術研究與生產力工具。

## 安裝方式

### 1. 添加 Marketplace

在 Claude Code 中執行：

```bash
/plugin marketplace add kiki830621/che-claude-plugins
```

### 2. 安裝 Plugin

```bash
/plugin install archive-mail@kiki830621/che-claude-plugins
```

或直接瀏覽：

```bash
/plugin
# 進入 Discover 頁籤
```

## 可用 Plugins

| Plugin | 說明 | 平台 |
|--------|------|------|
| [archive-mail](plugins/archive-mail/) | 自動歸檔 Apple Mail 郵件到 Markdown，使用 Message-ID 精確去重 | macOS |

## Plugin 詳情

### archive-mail

自動將 Apple Mail 中的郵件歸檔為結構化的 Markdown 檔案。

**功能特色**：
- 📧 Message-ID 精確去重（O(1) 查詢）
- 📎 自動下載附件（按日期分類）
- 🤖 AI 智慧摘要（提取重點和待辦事項）
- 📁 結構化 JSON 索引

**使用方式**：
```bash
/archive-mail
```

[查看完整文檔 →](plugins/archive-mail/README.md)

## 目錄結構

```
che-claude-plugins/
├── marketplace.json          # Marketplace 索引
├── plugins/
│   └── archive-mail/        # 郵件歸檔 plugin
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/
│       │   └── archive-mail.md
│       └── README.md
└── README.md
```

## 開發中的 Plugins

- [ ] `archive-line` - LINE 對話歸檔
- [ ] `meeting-notes` - 會議記錄生成
- [ ] `research-paper` - 學術論文輔助工具

## 貢獻

歡迎提交 Issue 或 Pull Request！

## 授權

MIT License

## 作者

**Che Cheng** (鄭澈)
- GitHub: [@kiki830621](https://github.com/kiki830621)
- Website: [che-cheng-website](https://kiki830621.github.io/che-cheng-website/)

---

*Made with ❤️ for the Claude Code community*
