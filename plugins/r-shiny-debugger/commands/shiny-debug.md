---
description: 功能測試導向的 R Shiny App Debug，整合前端 (agent-browser) 與後端 (R console)
argument-hint: [測試描述]
---

# R Shiny Debugger

功能測試導向的 R Shiny App Debug 工具。

## 使用方式

- `/shiny-debug` — 互動模式，列出 UI 元素後詢問測試目標
- `/shiny-debug 上傳後圖表更新` — 直接測試指定功能

## 執行步驟

### Step 1: 檢查前置需求

```bash
which agent-browser || echo "請先安裝: npm install -g agent-browser && agent-browser install"
which R || echo "請先安裝 R"
```

### Step 2: 偵測 Shiny App

```bash
ls app.R ui.R server.R 2>/dev/null
```

- `app.R` 存在 → 單檔模式
- `ui.R` + `server.R` → 雙檔模式
- 都沒有 → 詢問用戶 app 路徑

### Step 3: 啟動 App（背景執行）

```bash
mkdir -p .shiny-debug

# 檢查 port
lsof -i :3838 | grep LISTEN && echo "Port 3838 被占用"

# 啟動
Rscript -e "shiny::runApp('.', port=3838, launch.browser=FALSE)" 2>&1 | tee .shiny-debug/shiny.log &

# 等待啟動
for i in {1..30}; do
  grep -q "Listening on http" .shiny-debug/shiny.log 2>/dev/null && break
  sleep 1
done
```

### Step 4: 開啟瀏覽器

```bash
agent-browser open http://localhost:3838 --headed
agent-browser snapshot -i -c
```

展示 UI 元素：
```
- [@e1] fileInput "上傳檔案"
- [@e2] selectInput "選擇欄位"
- [@e3] actionButton "計算"
- [@e4] plotOutput
```

### Step 5: 確認測試目標

如果用戶提供了 `$ARGUMENTS`，解析測試描述並規劃步驟。

如果沒有，詢問：
```
你想測試什麼功能？
- "上傳 CSV 後圖表應該更新"
- "空輸入時不應該 crash"
- 或直接操作："click @e3"
```

### Step 6: 執行測試

**可用操作：**

| 操作 | 命令 |
|------|------|
| 點擊 | `agent-browser click @ref` |
| 輸入 | `agent-browser fill @ref "text"` |
| 選擇 | `agent-browser select @ref "value"` |
| 上傳 | `agent-browser upload @ref /path/file` |
| 等待 | `agent-browser wait 1000` |
| 截圖 | `agent-browser screenshot path.png` |
| 快照 | `agent-browser snapshot -i` |

**每步驟後檢查：**

```bash
# 前端
agent-browser console
agent-browser errors

# 後端
tail -20 .shiny-debug/shiny.log
grep -i "error" .shiny-debug/shiny.log | tail -5
```

### Step 7: 輸出報告

**成功：**
```
═══════════════════════════════════════════
測試: 上傳 CSV 後圖表會更新

1. ✅ 開啟 app
2. ✅ 上傳 test.csv → [後端] "Uploaded"
3. ✅ 選擇欄位 → [後端] "Rendering"
4. ✅ 圖表已更新

結果: ✅ 通過
═══════════════════════════════════════════
```

**失敗：**
```
═══════════════════════════════════════════
測試: 空輸入時不應 crash

❌ Step 2 失敗

[前端] Error: Column not found
[後端] Error in server.R:45

建議: 加入 req(input$col %in% names(data()))
═══════════════════════════════════════════
```

### Step 8: 清理

詢問用戶：
1. 繼續測試 → 回到 Step 5
2. 結束

```bash
agent-browser close
pkill -f "shiny::runApp"
```

## 測試檔案（可選）

如果有 `.shiny-tests.yaml`：

```yaml
tests:
  - name: test_upload
    description: "上傳後圖表更新"
    steps:
      - action: upload
        target: fileInput
        file: test.csv
      - action: verify
        expect:
          backend_log: "Rendering"
```

## 常見問題

**App 啟動失敗：**
```bash
cat .shiny-debug/shiny.log
```

**Port 被占用：**
```bash
kill $(lsof -t -i:3838)
```

**找不到元素：**
```bash
agent-browser snapshot -i
```
