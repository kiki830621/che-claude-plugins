# Archive Mail Plugin

[![Platform](https://img.shields.io/badge/platform-macOS-blue)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

自動歸檔 Apple Mail 郵件到 Markdown 檔案的 Claude Code Plugin。

## 功能特色

- **Message-ID 精確去重**：使用郵件唯一識別碼，避免重複歸檔
- **自動下載附件**：按日期分類存放附件
- **AI 智慧摘要**：自動提取重點和待辦事項
- **JSON 索引**：O(1) 快速查詢已歸檔郵件

## 安裝

### 方式一：從本地安裝

```bash
/plugin install archive-mail@/path/to/plugins/archive-mail
```

### 方式二：從 GitHub 安裝

```bash
# 如果已發布到 GitHub
/plugin install archive-mail@owner/repo
```

## 使用方式

```bash
/archive-mail
```

執行前請先修改 `commands/archive-mail.md` 中的配置區塊：

```yaml
account: "your-email@gmail.com"     # Mail.app 帳戶名稱
mailbox: "全部郵件"                  # 信箱名稱
output_dir: "communication/emails"  # 輸出目錄
attachments_dir: "communication/attachments"  # 附件目錄
index_file: "communication/.email_index.json" # 索引檔

sender_filters:
  - "professor@university.edu"      # 寄件人過濾條件
```

## 輸出結構

```
communication/
├── .email_index.json     # Message-ID 索引
├── emails/
│   ├── 20260106_meeting_request.md
│   └── 20260105_project_update.md
└── attachments/
    ├── 20260106/
    │   └── document.pdf
    └── 20260105/
        └── data.xlsx
```

## Markdown 格式

每封歸檔郵件包含：

1. **元數據表格**：日期、寄件人、收件人、類別、附件
2. **完整信件內容**
3. **AI 重點摘要**
4. **待辦事項清單**

## 技術實作

### 為什麼使用 AppleScript？

- **Message-ID 支援**：只有 AppleScript 能取得 `message id of msg`
- **附件下載**：MCP 無法下載郵件附件
- **精確去重**：Message-ID 是全球唯一識別碼

### Message-ID 索引

```json
{
  "version": "1.0",
  "last_updated": "2026-01-11",
  "emails": {
    "abc123@example.com": {
      "file": "20260106_topic.md",
      "date": "2026-01-06 00:30",
      "subject": "郵件主旨..."
    }
  }
}
```

## 系統需求

- **作業系統**：macOS（Ventura 或更新版本）
- **應用程式**：Apple Mail.app
- **Claude Code 權限**：
  - `Bash(osascript:*)` - AppleScript 執行
  - `Read`, `Write`, `Edit`, `Glob` - 檔案操作

## 授權

MIT License

## 作者

Che Cheng

---

*此 Plugin 原為林克忠教授實驗室開發的郵件歸檔工具，現已通用化供其他使用者使用。*
