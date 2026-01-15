# Archive Mail

歸檔 Apple Mail 郵件到 Markdown 檔案，使用 apple-mail MCP。

## 使用

```bash
/archive-mail d06227105@ntu.edu.tw
/archive-mail d06227105@ntu.edu.tw communication/emails
```

- 第一個參數：Email 過濾條件
- 第二個參數（可選）：輸出目錄，預設 `communication/emails`

## 前置需求

- apple-mail MCP server 已連接

## 功能

- 搜尋指定聯絡人的收/發郵件
- 轉換為 Markdown 格式
- Message-ID 去重，不會重複歸檔
- AI 提取重點摘要和待辦事項
