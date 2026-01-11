---
description: 歸檔 Apple Mail 郵件到 Markdown 檔案（含附件），使用 Message-ID 精確去重
allowed-tools: Bash(osascript:*), Bash(ls:*), Bash(mkdir:*), Read, Write, Glob, Edit
---

# Archive Mail Plugin

自動歸檔 Apple Mail 郵件到 Markdown 檔案，**使用 Message-ID 實現精確去重**。

## 配置區塊

**使用前請修改以下設定**：

```yaml
# 必填設定
account: "your-email@gmail.com"     # Mail.app 帳戶名稱
output_dir: "communication/emails"  # 輸出目錄
attachments_dir: "communication/attachments"  # 附件目錄

# 過濾條件（至少填一個）
filters:
  - "professor@university.edu"      # 寄件人/收件人包含此字串
  - "assistant@gmail.com"

# === 進階設定（收/發分類）===
# 若需要將收到和寄出的郵件分開存放：
separate_by_direction: true         # 啟用收/發分類
from_dir: "from_contact"            # 收到的郵件目錄
to_dir: "to_contact"                # 寄出的郵件目錄
from_index: ".email_index_from.json"  # 收信索引
to_index: ".email_index_to.json"      # 寄信索引
sent_mailbox: "寄件備份"              # 寄件匣名稱（Gmail）
received_mailbox: "全部郵件"          # 收件匣名稱（Gmail）
my_account: "my-email@gmail.com"      # 判斷寄/收的依據
```

---

## 執行步驟

### 1. 讀取 Message-ID 索引

讀取索引檔，載入所有已歸檔郵件的 Message-ID。

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

**若索引檔不存在**：自動建立空索引 `{"version": "1.0", "emails": {}}`

### 2. 搜尋郵件並提取 Message-ID

使用 AppleScript 搜尋郵件，**同時提取 Message-ID**：

```applescript
tell application "Mail"
    set output to ""

    repeat with acc in accounts
        if name of acc is "{{account}}" then
            repeat with mb in mailboxes of acc
                if name of mb is "{{mailbox}}" then
                    -- 搜尋寄件人
                    set msgs to (messages of mb whose sender contains "{{sender_filter}}")

                    repeat with msg in msgs
                        set msgId to message id of msg      -- 唯一識別碼
                        set msgSubj to subject of msg
                        set msgDate to date received of msg
                        set msgSender to sender of msg
                        set msgContent to content of msg

                        -- 格式化日期
                        set y to year of msgDate as text
                        set m to month of msgDate as integer
                        set d to day of msgDate as integer
                        set h to hours of msgDate as integer
                        set min to minutes of msgDate as integer
                        if m < 10 then set m to "0" & m
                        if d < 10 then set d to "0" & d
                        if h < 10 then set h to "0" & h
                        if min < 10 then set min to "0" & min
                        set dateStr to y & "-" & m & "-" & d & " " & h & ":" & min

                        set output to output & "=== EMAIL ===" & linefeed
                        set output to output & "MESSAGE_ID: " & msgId & linefeed
                        set output to output & "DATE: " & dateStr & linefeed
                        set output to output & "SENDER: " & msgSender & linefeed
                        set output to output & "SUBJECT: " & msgSubj & linefeed
                        set output to output & "CONTENT:" & linefeed & msgContent & linefeed
                        set output to output & "=== END ===" & linefeed & linefeed
                    end repeat
                end if
            end repeat
        end if
    end repeat
    return output
end tell
```

### 3. 比對索引篩選新郵件

對於每封搜尋到的郵件：
1. 提取其 `message id`（唯一識別碼）
2. 在索引中查詢該 Message-ID 是否存在
3. **若存在** → 跳過（已歸檔）
4. **若不存在** → 納入待歸檔清單

### 4. 處理附件

```applescript
tell application "Mail"
    set basePath to "{{attachments_dir}}/"

    -- 搜尋郵件並下載附件
    repeat with msg in targetMessages
        set msgDate to date received of msg

        -- 格式化日期為 YYYYMMDD
        set y to year of msgDate as text
        set m to month of msgDate as integer
        set d to day of msgDate as integer
        if m < 10 then set m to "0" & m
        if d < 10 then set d to "0" & d
        set dateStr to y & m & d

        -- 檢查並下載附件
        try
            set attachmentList to mail attachments of msg
            if (count of attachmentList) > 0 then
                repeat with anAttachment in attachmentList
                    set attName to name of anAttachment
                    set savePath to basePath & dateStr & "/" & attName
                    try
                        save anAttachment in POSIX file savePath
                    end try
                end repeat
            end if
        end try
    end repeat
end tell
```

**附件存放規則**：
- **目錄結構**：`attachments/YYYYMMDD/`
- **檔名**：保留原始檔名
- 下載前先建立目錄：`mkdir -p attachments/YYYYMMDD/`

### 5. 生成 Markdown

為每封未歸檔郵件生成 markdown 檔案：

**必須包含的區塊**：
1. **標題**：`# [主題簡述] - YYYY-MM-DD HH:MM`
2. **元數據**：日期、寄件人、收件人、類別、附件（若有）
3. **信件內容**：完整保留原始信件內容
4. **重點摘要**：AI 提取關鍵要點
5. **待辦事項**：AI 提取需要行動的項目
6. **頁腳**：歸檔日期

**格式範例**：

```markdown
# 會議邀約 - 2025-12-31 00:26

## 元數據

| 項目 | 內容 |
|------|------|
| **日期** | 2025-12-31 00:26 |
| **寄件人** | 教授姓名 |
| **收件人** | 收件人 |
| **類別** | 會議邀約 |
| **附件** | [文件.pdf](../attachments/20251231/文件.pdf) |

---

## 信件內容

[完整郵件內容...]

---

## 重點摘要

- ...

## 待辦事項

- [ ] ...

---

*歸檔日期：2026-01-11*
```

### 6. 寫入檔案

- **命名格式**：`YYYYMMDD_brief_description.md`
- **brief_description**：根據主旨生成簡潔的英文描述（全小寫、底線連接）
- **位置**：`{{output_dir}}/`

### 7. 更新 Message-ID 索引

歸檔完成後，立即將新郵件的 Message-ID 加入索引：

```json
{
  "version": "1.0",
  "last_updated": "YYYY-MM-DD",
  "emails": {
    "新郵件的Message-ID@domain.com": {
      "file": "YYYYMMDD_brief_description.md",
      "date": "YYYY-MM-DD HH:MM",
      "subject": "郵件主旨前50字..."
    }
  }
}
```

### 8. 輸出報告

完成後報告：
- 已歸檔郵件數量
- 新增的檔案列表
- 下載的附件列表
- 跳過的郵件數量（已在索引中）

---

## 完整工作流程

```
1. 讀取 Message-ID 索引 (.email_index.json)
      ↓
2. AppleScript 搜尋郵件 + 提取 Message-ID
      ↓
3. 比對索引
      ├─ 已在索引 → 跳過
      └─ 不在索引 → 納入待歸檔
      ↓
4. 下載附件 (AppleScript)
      ↓
5. 生成 Markdown 檔案
      ↓
6. 寫入 output_dir
      ↓
7. 更新 Message-ID 索引
      ↓
8. 輸出報告
```

---

## AppleScript 關鍵語法

| 操作 | AppleScript |
|------|-------------|
| 搜尋郵件 | `messages of mb whose sender contains "keyword"` |
| **取得 Message-ID** | `message id of msg` |
| 取得主旨 | `subject of msg` |
| 取得內容 | `content of msg` |
| 取得日期 | `date received of msg` |
| 取得寄件人 | `sender of msg` |
| 列出附件 | `mail attachments of msg` |
| 下載附件 | `save anAttachment in POSIX file savePath` |

---

## 去重機制說明

### Message-ID 的優勢

- **全球唯一**：由郵件伺服器生成，格式如 `abc123@ntu.edu.tw`
- **精確比對**：不會有模糊匹配的誤判
- **效能提升**：JSON 索引查詢 O(1)，比逐檔讀取比對 O(n) 快很多

### Message-ID 格式範例

| 來源 | 格式範例 |
|------|----------|
| 大學 | `d772fcfc23ff499abb4dbc14af049f9d@ntu.edu.tw` |
| Gmail | `CAJzoM9kyK=v8YT7WE1QcE...@mail.gmail.com` |
| Outlook | `TYYP301MB1301...@TYYP301MB1301.JPNP301.PROD.OUTLOOK.COM` |

---

## 常見問題

### Q1: AppleScript 無法找到郵件？

先驗證帳戶和信箱名稱：

```applescript
tell application "Mail"
    repeat with acc in accounts
        log "帳戶: " & name of acc
        repeat with mb in mailboxes of acc
            log "  信箱: " & name of mb
        end repeat
    end repeat
end tell
```

### Q2: 附件下載失敗？

先確保目錄存在：

```bash
mkdir -p "attachments/YYYYMMDD/"
```

### Q3: 為什麼使用 AppleScript 而非 MCP？

apple-mail MCP 無法提供 Message-ID，無法實現精確的去重判斷。AppleScript 可以透過 `message id of msg` 取得唯一識別碼。

---

## 平台支援

- **僅支援 macOS**：需要 Mail.app 和 AppleScript
- **測試版本**：macOS Ventura, Sonoma, Sequoia
