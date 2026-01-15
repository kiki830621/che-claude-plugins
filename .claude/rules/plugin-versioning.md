# Plugin 版本管理規則

## Marketplace 更新必須同步兩個檔案

當修改任何 plugin 內容時（包括 commands、skills），**必須同時更新**：

1. `plugins/<name>/.claude-plugin/plugin.json` - Plugin 自身的版本
2. `.claude-plugin/marketplace.json` - Marketplace 的 plugins 列表

### 原因

- `plugin.json`：Claude Code 使用版本號判斷是否需要重新載入
- `marketplace.json`：Marketplace 使用此檔案列出可安裝的 plugins

如果只修改其中一個，會導致版本不同步或 plugin 無法被發現。

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
- [ ] 更新 `marketplace.json` 中對應 plugin 的 `version` 欄位
- [ ] 更新 `description` 如果功能有變化（兩個檔案都要）
- [ ] 更新 `keywords` 如果有新功能
- [ ] Commit message 包含版本號（如 `v2.0.0`）

### 新增/刪除/重命名 Plugin 時

除了上述 checklist，還需要：

- [ ] 在 `marketplace.json` 的 `plugins` 陣列中新增/刪除/修改對應項目
- [ ] 更新 `README.md` 的 plugins 列表

### 範例

**plugin.json**:
```json
{
  "version": "2.0.0",
  "description": "新描述"
}
```

**marketplace.json**:
```json
{
  "plugins": [
    {
      "name": "my-plugin",
      "version": "2.0.0",  // 必須與 plugin.json 一致
      "description": "新描述",
      "source": "./plugins/my-plugin"
    }
  ]
}
```
