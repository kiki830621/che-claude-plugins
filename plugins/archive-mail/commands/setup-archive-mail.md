---
description: 為當前專案設置 /archive-mail-[name] 命令（配置聯絡人、目錄、索引）
allowed-tools: Read, Write, Bash(mkdir:*), Glob, AskUserQuestion
---

# Setup Archive Mail

為當前專案快速配置 `/archive-mail-[name]` 命令。

**命名規則**：生成的命令會是 `/archive-mail-[name]`，例如：
- `/archive-mail-kehchunglin`
- `/archive-mail-chen`
- `/archive-mail-labA`

## 執行流程

### 1. 收集配置資訊

使用 AskUserQuestion 詢問：

**問題 1：命令名稱 (name)**
- 用於命令名稱：`/archive-mail-[name]`
- 用於目錄名稱：`from_[name]/`, `to_[name]/`
- 範例：`kehchunglin`, `chen`, `labA`
- **規則**：小寫英文、無空格、可用底線

**問題 2：Mail.app 帳戶名稱**
- 選項：列出常見格式或讓用戶輸入
- 範例：`statisticalearning123@gmail.com`

**問題 3：要追蹤的聯絡人 Email**
- 可多個，用逗號分隔
- 範例：`kehchunglin@ntu.edu.tw, kclassistant@gmail.com`

**問題 4：聯絡人顯示名稱（中文）**
- 用於文件描述
- 範例：`林克忠教授`

**問題 5：是否區分收/發郵件**
- 是：建立 `from_[name]/` 和 `to_[name]/` 兩個目錄
- 否：全部放在 `[name]/` 一個目錄

**問題 6：輸出目錄名稱**
- 預設：`communication/emails`
- 可自訂

### 2. 建立目錄結構

```bash
mkdir -p .claude/commands
mkdir -p {{output_dir}}
mkdir -p communication/attachments
```

若選擇收/發分類：
```bash
mkdir -p {{output_dir}}/from_{{name}}
mkdir -p {{output_dir}}/to_{{name}}
```

### 3. 生成 archive-mail-[name].md

根據收集的配置，生成專案特定的命令檔案：

**檔案名稱**：`.claude/commands/archive-mail-{{name}}.md`

```markdown
---
description: 歸檔{{display_name}}的郵件（收/發分類）
allowed-tools: Bash(osascript:*), Bash(ls:*), Bash(mkdir:*), Bash(mv:*), Read, Write, Glob, Edit
---

## 任務

歸檔{{display_name}}相關郵件到收/發分類目錄。

### 目錄結構

\`\`\`
{{output_dir}}/
├── from_{{name}}/    # 收到的郵件
└── to_{{name}}/      # 寄出的郵件
\`\`\`

### 過濾條件

**收到的郵件 (from_{{name}}/)**：
{{#each filters}}
- `{{this}}` 在寄件人
{{/each}}

**寄出的郵件 (to_{{name}}/)**：
{{#each filters}}
- `{{this}}` 在收件人
{{/each}}
- 且寄件人是 `{{my_account}}`

[其餘內容從基礎模板生成...]
```

### 4. 建立索引檔

若選擇收/發分類，建立兩個索引：

**{{output_dir}}/.email_index_{{name}}_from.json**:
```json
{
  "version": "1.0",
  "type": "from_{{name}}",
  "last_updated": "{{today}}",
  "description": "收到的郵件索引（{{display_name}}）",
  "emails": {}
}
```

**{{output_dir}}/.email_index_{{name}}_to.json**:
```json
{
  "version": "1.0",
  "type": "to_{{name}}",
  "last_updated": "{{today}}",
  "description": "寄出的郵件索引（{{display_name}}）",
  "emails": {}
}
```

### 5. 更新 settings.local.json（若需要）

確保 `.claude/settings.local.json` 包含必要權限：

```json
{
  "permissions": {
    "allow": [
      "Bash(osascript:*)",
      "Bash(mkdir:*)",
      "Bash(mv:*)"
    ]
  }
}
```

### 6. 輸出確認

完成後顯示：

```
✅ /archive-mail-{{name}} 已配置完成！

📁 建立的檔案：
   - .claude/commands/archive-mail-{{name}}.md
   - {{output_dir}}/.email_index_{{name}}_from.json
   - {{output_dir}}/.email_index_{{name}}_to.json
   - {{output_dir}}/from_{{name}}/
   - {{output_dir}}/to_{{name}}/

📧 追蹤的聯絡人（{{display_name}}）：
{{#each filters}}
   - {{this}}
{{/each}}

🚀 使用方式：
   執行 /archive-mail-{{name}} 開始歸檔郵件
```

---

## 配置模板

以下是完整的 archive-mail.md 模板，將 `{{placeholder}}` 替換為實際值：

```
---
description: 歸檔{{contact_name}}的郵件（收/發分類）
allowed-tools: Bash(osascript:*), Bash(ls:*), Bash(mkdir:*), Bash(mv:*), Read, Write, Glob, Edit
---

## 任務

模擬「{{project_name}}」智慧型信箱，歸檔相關郵件到收/發分類目錄，**包含附件下載**。

### 目錄結構

\`\`\`
{{output_dir}}/
├── {{from_dir}}/    # 收到的郵件
└── {{to_dir}}/      # 寄出的郵件
\`\`\`

### 過濾條件

**收到的郵件 ({{from_dir}}/)**：
{{#each filters}}
- `{{this}}` 在寄件人
{{/each}}

**寄出的郵件 ({{to_dir}}/)**：
{{#each filters}}
- `{{this}}` 在收件人
{{/each}}
- 且寄件人是 `{{my_account}}`

### 技術方案

**使用 AppleScript (osascript)** 操作 Mail.app，因為：
- AppleScript 可以提取 **Message-ID**（郵件唯一識別碼）
- MCP 無法提供 Message-ID，無法實現精確的去重判斷
- AppleScript 是 macOS 內建，不需額外安裝

---

## 執行步驟

### 1. 讀取 Message-ID 索引

讀取兩個索引檔：
- `{{output_dir}}/.email_index_from.json` - 收到的郵件索引
- `{{output_dir}}/.email_index_to.json` - 寄出的郵件索引

[完整步驟從基礎模板繼承...]
```

---

## 變數說明

| 變數 | 說明 | 範例 |
|------|------|------|
| `{{contact_name}}` | 聯絡人名稱（中文） | 林克忠教授 |
| `{{project_name}}` | 專案名稱 | 林克忠實驗室 |
| `{{my_account}}` | 自己的郵件帳戶 | statisticalearning123@gmail.com |
| `{{output_dir}}` | 輸出目錄 | communication/emails |
| `{{from_dir}}` | 收信目錄名稱 | from_kehchunglin |
| `{{to_dir}}` | 寄信目錄名稱 | to_kehchunglin |
| `{{filters}}` | 過濾條件列表 | ["kehchunglin@ntu.edu.tw", "kclassistant@gmail.com"] |
