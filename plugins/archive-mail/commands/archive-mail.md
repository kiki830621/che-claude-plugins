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
```

---

## 執行步驟

### 0. 環境偵測（每次執行前必做）

**先執行此 AppleScript 列出所有帳號和信箱**：

```applescript
tell application "Mail"
    set output to ""
    repeat with acc in accounts
        set output to output & "ACCOUNT: " & (name of acc) & linefeed
        repeat with mb in mailboxes of acc
            set output to output & "  - " & (name of mb) & linefeed
        end repeat
    end repeat
    return output
end tell
```

**預期輸出範例**：
```
ACCOUNT: your-email@gmail.com
  - 收件匣
  - 重要郵件
  - 全部郵件
  - 寄件備份
  ...
ACCOUNT: another@domain.com
  - 收件匣
  - 寄件備份
  ...
```

**注意**：
- 帳號名稱是完整 email 地址（不是 "Gmail"）
- 信箱名稱可能是中文（`收件匣`）或英文（`INBOX`）
- 根據偵測結果調整後續搜尋

---

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

### 2. 搜尋收到的郵件

使用 AppleScript **遍歷所有帳號和信箱**搜尋寄件人包含指定聯絡人的郵件：

```applescript
tell application "Mail"
    set output to ""
    set processedIds to {}

    -- 遍歷所有帳號（不硬編碼帳號名稱）
    repeat with acc in accounts
        repeat with mb in mailboxes of acc
            try
                -- 搜尋寄件人包含指定關鍵字
                set msgs to (messages of mb whose sender contains "{{filter}}")

                repeat with msg in msgs
                    set msgId to message id of msg

                    -- 去重：避免同一封郵件在多個信箱出現
                    if msgId is not in processedIds then
                        set end of processedIds to msgId

                        set msgSubj to subject of msg
                        set msgDate to date received of msg
                        set msgSender to sender of msg
                        set msgContent to content of msg

                        -- 格式化日期
                        set y to year of msgDate as string
                        set m to text -2 thru -1 of ("0" & ((month of msgDate) as integer))
                        set d to text -2 thru -1 of ("0" & (day of msgDate))
                        set h to text -2 thru -1 of ("0" & (hours of msgDate))
                        set mi to text -2 thru -1 of ("0" & (minutes of msgDate))
                        set dateStr to y & "-" & m & "-" & d & " " & h & ":" & mi

                        set output to output & "=== EMAIL ===" & linefeed
                        set output to output & "MESSAGE_ID: " & msgId & linefeed
                        set output to output & "TYPE: FROM" & linefeed
                        set output to output & "DATE: " & dateStr & linefeed
                        set output to output & "SENDER: " & msgSender & linefeed
                        set output to output & "SUBJECT: " & msgSubj & linefeed
                        set output to output & "CONTENT:" & linefeed & msgContent & linefeed
                        set output to output & "=== END ===" & linefeed & linefeed
                    end if
                end repeat
            on error errMsg
                -- 跳過無法存取的信箱（如系統信箱）
            end try
        end repeat
    end repeat
    return output
end tell
```

**改進重點**：
- ✅ 遍歷所有帳號（不硬編碼帳號名稱）
- ✅ 遍歷所有信箱（不限 `全部郵件`，也搜 `收件匣`、`重要郵件` 等）
- ✅ 去重機制（同一封郵件可能在多個信箱出現）
- ✅ 錯誤處理（跳過無法存取的信箱）

### 3. 搜尋寄出的郵件

搜尋**所有帳號的已傳送郵件**中收件人包含指定聯絡人的郵件：

```applescript
tell application "Mail"
    set output to ""
    set processedIds to {}

    -- 定義已傳送信箱的可能名稱（中英文）
    set sentMailboxNames to {"寄件備份", "Sent", "已傳送郵件", "[Gmail]/已傳送郵件", "Sent Messages"}

    repeat with acc in accounts
        repeat with mb in mailboxes of acc
            try
                -- 檢查是否為已傳送信箱
                if (name of mb) is in sentMailboxNames then
                    set allMsgs to messages of mb

                    repeat with msg in allMsgs
                        -- 檢查收件人是否包含指定聯絡人
                        set recipientList to recipients of msg
                        set isTarget to false
                        repeat with rcpt in recipientList
                            set rcptAddr to address of rcpt
                            if rcptAddr contains "{{filter}}" then
                                set isTarget to true
                                exit repeat
                            end if
                        end repeat

                        if isTarget then
                            set msgId to message id of msg

                            -- 去重
                            if msgId is not in processedIds then
                                set end of processedIds to msgId

                                set msgSubj to subject of msg
                                set msgDate to date sent of msg
                                set msgContent to content of msg

                                -- 格式化日期
                                set y to year of msgDate as string
                                set m to text -2 thru -1 of ("0" & ((month of msgDate) as integer))
                                set d to text -2 thru -1 of ("0" & (day of msgDate))
                                set h to text -2 thru -1 of ("0" & (hours of msgDate))
                                set mi to text -2 thru -1 of ("0" & (minutes of msgDate))
                                set dateStr to y & "-" & m & "-" & d & " " & h & ":" & mi

                                set output to output & "=== EMAIL ===" & linefeed
                                set output to output & "MESSAGE_ID: " & msgId & linefeed
                                set output to output & "TYPE: TO" & linefeed
                                set output to output & "DATE: " & dateStr & linefeed
                                set output to output & "RECIPIENT: " & (address of item 1 of recipientList) & linefeed
                                set output to output & "SUBJECT: " & msgSubj & linefeed
                                set output to output & "CONTENT:" & linefeed & msgContent & linefeed
                                set output to output & "=== END ===" & linefeed & linefeed
                            end if
                        end if
                    end repeat
                end if
            on error errMsg
                -- 跳過無法存取的信箱
            end try
        end repeat
    end repeat
    return output
end tell
```

**改進重點**：
- ✅ 遍歷所有帳號（不硬編碼帳號名稱）
- ✅ 支援多種已傳送信箱名稱（中英文）
- ✅ 去重機制
- ✅ 錯誤處理

### 4. 比對索引篩選新郵件

對於每封搜尋到的郵件：
1. 提取其 `message id`（唯一識別碼）
2. 根據 TYPE 選擇對應索引（from 或 to）
3. 在索引中查詢該 Message-ID 是否存在
4. **若存在** → 跳過（已歸檔）
5. **若不存在** → 納入待歸檔清單

### 5. 處理附件

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

### 6. 生成 Markdown

根據郵件類型存放到不同目錄：

**收到的郵件**：`{{output_dir}}/{{from_dir}}/YYYYMMDD_description.md`
**寄出的郵件**：`{{output_dir}}/{{to_dir}}/YYYYMMDD_description.md`

**必須包含的區塊**：
1. **標題**：`# [主題簡述] - YYYY-MM-DD HH:MM`
2. **元數據**：日期、寄件人、收件人、類別、附件（若有）
3. **信件內容**：完整保留原始信件內容
4. **重點摘要**：AI 提取關鍵要點（收信時）
5. **待辦事項**：AI 提取需要行動的項目（收信時）
6. **頁腳**：歸檔日期

**格式範例（收到）**：

```markdown
# 會議邀約 - 2025-12-31 00:26

## 元數據

| 項目 | 內容 |
|------|------|
| **日期** | 2025-12-31 00:26 |
| **類型** | 收到 |
| **寄件人** | 教授姓名 |
| **收件人** | 收件人 |
| **類別** | 會議邀約 |
| **附件** | [文件.pdf](../../attachments/20251231/文件.pdf) |

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

**格式範例（寄出）**：

```markdown
# Re: 分析結果報告 - 2026-01-07 14:30

## 元數據

| 項目 | 內容 |
|------|------|
| **日期** | 2026-01-07 14:30 |
| **類型** | 寄出 |
| **寄件人** | 我 |
| **收件人** | 教授姓名 |
| **類別** | 研究報告 |

---

## 信件內容

[完整郵件內容...]

---

*歸檔日期：2026-01-11*
```

**注意**：寄出的郵件通常不需要「重點摘要」和「待辦事項」區塊

### 7. 更新 Message-ID 索引

根據郵件類型更新對應索引：
- 收到 → `.email_index_from.json`
- 寄出 → `.email_index_to.json`

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
- 已歸檔郵件數量（分收/發）
- 新增的檔案列表
- 下載的附件列表
- 跳過的郵件數量（已在索引中）

---

## 完整工作流程

```
0. 環境偵測（列出帳號/信箱）
      ↓
1. 讀取 Message-ID 索引
      ↓
2. AppleScript 搜尋收到的郵件 (sender 過濾)
      ↓
3. AppleScript 搜尋寄出的郵件 (recipient 過濾)
      ↓
4. 比對索引
      ├─ 已在索引 → 跳過
      └─ 不在索引 → 納入待歸檔
      ↓
5. 下載附件 (AppleScript)
      ↓
6. 生成 Markdown 檔案
      ├─ 收到 → from_xxx/
      └─ 寄出 → to_xxx/
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
| 取得收信日期 | `date received of msg` |
| 取得寄信日期 | `date sent of msg` |
| 取得寄件人 | `sender of msg` |
| 取得收件人 | `recipients of msg` |
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

先執行 Step 0 環境偵測，確認帳戶和信箱名稱。

### Q2: 附件下載失敗？

先確保目錄存在：

```bash
mkdir -p "attachments/YYYYMMDD/"
```

### Q3: 為什麼使用 AppleScript 而非 MCP？

apple-mail MCP 無法提供 Message-ID，無法實現精確的去重判斷。AppleScript 可以透過 `message id of msg` 取得唯一識別碼。

### Q4: 同一封郵件在多個信箱出現怎麼辦？

新版本使用 `processedIds` 列表在搜尋過程中去重，避免重複處理。

---

## 平台支援

- **僅支援 macOS**：需要 Mail.app 和 AppleScript
- **測試版本**：macOS Ventura, Sonoma, Sequoia
