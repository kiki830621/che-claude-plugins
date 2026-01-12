# Archive Mail Plugin

[![Platform](https://img.shields.io/badge/platform-macOS-blue)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

自動歸檔 Apple Mail 郵件到 Markdown 檔案的 Claude Code Plugin。

## 功能特色

- **Message-ID 精確去重**：使用郵件唯一識別碼，避免重複歸檔
- **自動下載附件**：按日期分類存放附件
- **AI 智慧摘要**：自動提取重點和待辦事項
- **JSON 索引**：O(1) 快速查詢已歸檔郵件
- **收/發分類**：可將收到和寄出的郵件分開存放
- **彈性搜尋**：遍歷所有帳號和信箱，支援中英文信箱名稱

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

### 快速開始

```bash
# 設置新的郵件歸檔（互動式）
/setup-archive-mail

# 歸檔郵件
/archive-mail
```

### 配置說明

執行前請先修改 `commands/archive-mail.md` 中的配置區塊：

```yaml
output_dir: "communication/emails"  # 輸出目錄
attachments_dir: "communication/attachments"  # 附件目錄

# 過濾條件
filters:
  - "professor@university.edu"      # 寄件人/收件人過濾條件

# 收/發分類
separate_by_direction: true
from_dir: "from_contact"
to_dir: "to_contact"
```

## 輸出結構

```
communication/
├── .email_index_from.json   # 收信 Message-ID 索引
├── .email_index_to.json     # 寄信 Message-ID 索引
├── emails/
│   ├── from_contact/
│   │   └── 20260106_meeting_request.md
│   └── to_contact/
│       └── 20260105_reply.md
└── attachments/
    └── 20260106/
        └── document.pdf
```

## Markdown 格式

每封歸檔郵件包含：

1. **元數據表格**：日期、類型、寄件人、收件人、類別、附件
2. **完整信件內容**
3. **AI 重點摘要**（收信時）
4. **待辦事項清單**（收信時）

## 技術實作

### 為什麼使用 AppleScript？

- **Message-ID 支援**：只有 AppleScript 能取得 `message id of msg`
- **附件下載**：MCP 無法下載郵件附件
- **精確去重**：Message-ID 是全球唯一識別碼

### v2.0 改進（2026-01-12）

- **環境偵測**：新增 Step 0，自動列出所有帳號和信箱名稱
- **彈性搜尋**：遍歷所有帳號，不再硬編碼帳號名稱
- **多語系支援**：支援中英文信箱名稱（`寄件備份`、`Sent`、`Sent Messages` 等）
- **去重機制**：使用 `processedIds` 避免同一封郵件在多個信箱重複處理
- **錯誤處理**：`try-on error` 跳過無法存取的系統信箱

### Message-ID 索引

```json
{
  "version": "1.0",
  "last_updated": "2026-01-11",
  "emails": {
    "abc123@example.com": {
      "file": "from_contact/20260106_topic.md",
      "date": "2026-01-06 00:30",
      "subject": "郵件主旨..."
    }
  }
}
```

## 常見問題

### Q1: AppleScript 無法找到郵件？

執行 `/archive-mail` 時會先執行環境偵測，確認：
- 帳號名稱是完整 email 地址（如 `your@gmail.com`，不是 "Gmail"）
- 信箱名稱可能是中文（`收件匣`、`寄件備份`）或英文（`INBOX`、`Sent`）

### Q2: 同一封郵件出現在多個信箱？

新版本使用 `processedIds` 列表在搜尋過程中去重，確保每封郵件只處理一次。

### Q3: 為什麼不用 apple-mail MCP？

apple-mail MCP 無法提供 Message-ID，無法實現精確的去重判斷。

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
