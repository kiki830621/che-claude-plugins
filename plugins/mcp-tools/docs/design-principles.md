# MCP Tools 設計原理

本文件記錄 mcp-tools plugin 各命令的設計決策和原理。

---

## 命令分工設計

### 開發 vs 使用分離

```
開發者視角                    使用者視角
    │                             │
    ▼                             ▼
┌──────────────┐           ┌──────────────┐
│  mcp-deploy  │  ──────→  │  mcp-install │
└──────────────┘  發布後   └──────────────┘
    │                             │
本地編譯+發布                從 GitHub 下載
```

**為什麼分開？**

| 考量 | mcp-deploy | mcp-install |
|------|------------|-------------|
| **版本來源** | 本地 build（可能未 commit） | GitHub Release（已發布） |
| **可重現性** | 低（依賴本地環境） | 高（任何人都能下載同版本） |
| **使用情境** | 開發機器 | 任何機器 |
| **需要原始碼** | 是 | 否 |

**設計原則**：Reproducibility > Convenience

---

## mcp-deploy 設計

### Phase 設計

```
Phase 0: 檢測 → Phase 1: 編譯 → Phase 2: 打包 → Phase 3: 發布
```

**為什麼用 Phase？**
1. **可中斷**：每個 Phase 完成後都是穩定狀態
2. **可跳過**：未來可支援 `--skip-build` 等參數
3. **易除錯**：問題發生時容易定位是哪個階段

### Universal Binary

```bash
swift build -c release --arch arm64
swift build -c release --arch x86_64
lipo -create ... -output
```

**為什麼不只編譯 arm64？**
- 相容性：仍有使用者使用 Intel Mac
- 發布一次：不需要維護兩個 binary
- macOS 標準：Apple 自己的 binary 都是 Universal

### MCPB 套件結構

```
mcpb/
├── manifest.json      # 套件 metadata
├── PRIVACY.md         # 隱私政策（MCPB 規範要求）
├── server/            # 執行檔
│   └── BinaryName
└── project.mcpb       # 打包後的 ZIP
```

**為什麼 .mcpb 放在 mcpb/ 內？**
- 避免根目錄混亂
- 方便 .gitignore 管理
- 與 server/ 和 manifest.json 放一起，結構清晰

---

## mcp-install 設計

### 只從 GitHub 下載

**為什麼不支援本地安裝？**

```
選項 A: 本地 + GitHub    選項 B: 只有 GitHub ✓
    │                         │
複雜度高                   單一來源
版本混淆                   版本明確
難以重現                   可重現
```

**設計決策**：mcp-deploy 結尾已經會 `cp` 到 `~/bin`，所以開發階段不需要另外的本地安裝命令。

### gh CLI vs curl

```bash
# gh（選用）
gh release download v1.2.0 --pattern "Binary" --output ~/bin/Binary

# curl（替代方案）
curl -L -o ~/bin/Binary https://github.com/.../releases/download/v1.2.0/Binary
```

**為什麼用 gh？**
1. **認證**：私有 repo 自動處理認證
2. **簡潔**：`--pattern` 可以只下載特定檔案
3. **錯誤處理**：版本不存在時有清楚錯誤訊息

---

## mcp-upgrade 設計

### 分析範圍

```
依賴更新 (deps)     結構優化 (structure)    功能建議 (features)
    │                     │                      │
    ▼                     ▼                      ▼
MCP SDK 版本         缺少 LICENSE?           批次操作?
其他套件更新         缺少 CHANGELOG?         搜尋功能?
```

**為什麼分三類？**
- 使用者可以選擇只看某一類
- 不同類別的修復優先級不同
- 避免報告過長

### 功能建議邏輯

```
現有 tools 分析
    │
    ▼
有 create_X 但沒有 create_X_batch? → 建議批次操作
有 get_X 但沒有 search_X?          → 建議搜尋功能
有 list_X 但沒有 get_X_detail?     → 建議詳情功能
```

**設計原則**：基於現有 tools 推斷缺失功能，而非通用建議

---

## 除錯流程設計

### 三層診斷

```
diagnose (連線層) → debug (功能層) → test (驗證層)
     │                  │                │
     ▼                  ▼                ▼
  Server 能連?      功能有 bug?      所有功能正常?
```

**為什麼分三個命令？**

| 情境 | 適合命令 |
|------|----------|
| Server 完全無反應 | diagnose |
| 某功能報錯 | debug |
| 開發完成想驗證 | test |

**設計原則**：從粗到細，逐步縮小問題範圍

---

## 檔案組織設計

### 目錄結構

```
mcp-tools/
├── .claude-plugin/
│   └── plugin.json      # Plugin metadata
├── commands/            # Skill 定義檔
│   ├── new-mcp-app.md
│   ├── mcp-deploy.md
│   ├── mcp-install.md
│   ├── mcp-upgrade.md
│   ├── diagnose.md
│   ├── debug.md
│   └── test.md
├── docs/                # 設計文檔
│   └── design-principles.md
└── README.md            # 使用說明
```

**為什麼 commands/ 用 .md？**
- Claude Code Skill 格式要求
- Markdown 可讀性高
- 支援 YAML front matter 定義 metadata

### 命名慣例

| 類型 | 命名 | 範例 |
|------|------|------|
| 開發流程 | `mcp-*` | mcp-deploy, mcp-install |
| 除錯工具 | 動詞 | diagnose, debug, test |

---

## 版本策略

### Semantic Versioning

```
MAJOR.MINOR.PATCH
  │     │     │
  │     │     └── Bug fix, 文檔更新
  │     └──────── 新功能（向後相容）
  └────────────── 破壞性變更
```

### 變更紀錄

| 版本 | 類型 | 說明 |
|------|------|------|
| 1.5.0 | MINOR | 新增 mcp-install |
| 1.4.x | PATCH | 修正 manifest 格式 |
| 1.2.0 | MINOR | 新增 mcp-deploy, mcp-upgrade |
| 1.1.0 | MINOR | 新增 debug, test |
| 1.0.0 | MAJOR | 初始版本 |

---

## 未來考量

### 可能的擴展

1. **mcp-init**：在現有專案加入 MCP 支援（vs new-mcp-app 建立新專案）
2. **mcp-publish**：發布到 MCPB marketplace（如果有的話）
3. **mcp-doctor**：整合 diagnose + debug + test 的一站式健康檢查

### 不會加入的功能

1. **GUI**：保持 CLI-first 設計
2. **自動修復**：只提供建議，修復交給使用者決定
3. **多專案管理**：每個專案獨立，避免 monorepo 複雜度
