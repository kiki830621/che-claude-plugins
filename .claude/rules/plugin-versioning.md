# Plugin 版本管理規則

## Marketplace 更新必須更新版本號

當修改任何 plugin 內容時（包括 commands、skills），**必須同時更新 `plugin.json` 的版本號**。

### 原因

Claude Code 使用版本號來判斷是否需要重新載入 plugin。如果只修改內容而不更新版本號：
1. 本地執行 `/plugin` 會提示更新
2. 但 marketplace 安裝的用戶可能不會收到更新

### 版本號規則 (Semantic Versioning)

```
MAJOR.MINOR.PATCH
```

| 變更類型 | 版本號位置 | 範例 |
|----------|-----------|------|
| 新增框架/大功能 | MAJOR | 1.0.0 → 2.0.0 |
| 新增 command/skill | MINOR | 1.0.0 → 1.1.0 |
| Bug 修復/小改動 | PATCH | 1.0.0 → 1.0.1 |

### Checklist

每次修改 plugin 時：

- [ ] 更新 `plugin.json` 的 `version` 欄位
- [ ] 更新 `description` 如果功能有變化
- [ ] 更新 `keywords` 如果有新功能
- [ ] Commit message 包含版本號（如 `v2.0.0`）

### 範例

```json
// 修改前
{
  "version": "1.1.0",
  "description": "舊描述"
}

// 修改後
{
  "version": "2.0.0",
  "description": "新描述，包含新功能說明"
}
```
