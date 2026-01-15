---
description: 診斷 MCP Server 連線問題（使用 Claude Code MCP 環境）
argument-hint: <mcp-server-name>
allowed-tools: Bash(ls:*, file:*, claude:mcp*), Read, Grep, mcp__*
---

# MCP Diagnose

診斷 MCP Server 連線問題的自動化工具。**優先使用 Claude Code MCP 環境測試**。

## 使用方式

```
/mcp-diagnose che-things-mcp
/mcp-diagnose <mcp-server-name>
```

- 參數：MCP Server 名稱（在 Claude Code 中已連接的 server）

## 診斷模式

### 模式 A：Claude Code MCP 環境（推薦）

如果 MCP Server 已經在 Claude Code 中連接，直接使用 MCP tools 測試。

**優點**：
- 不需要手動處理 stdin/stdout
- 測試結果更可靠
- 可以測試完整的 tools/call 功能

### 模式 B：Binary 測試

如果 MCP Server 尚未連接，使用傳統的 binary 測試方式。

## 診斷流程

### Step 1: 檢查 MCP 連線狀態

```bash
claude mcp list
```

找到目標 MCP Server 的連線狀態和 binary 路徑。

### Step 2: 基本連線測試

**如果已在 Claude Code 連接**：
直接呼叫一個簡單的 read-only tool 來測試連線：

```
# 例如 che-things-mcp
呼叫 mcp__che-things-mcp__get_projects
```

**如果未連接**：
使用 binary 測試 initialize：

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"initialize",...}' | timeout 5 "$MCP_BIN"
```

### Step 3: Tools List 測試

**如果已連接**：
從 Step 2 的成功呼叫可以推斷 tools/list 正常。

**如果未連接**：
測試 tools/list 回應是否正確。

### Step 4: Tools Call 測試

**如果已連接**：
依序呼叫幾個代表性的工具：
- 一個 read-only 工具（如 `get_today`）
- 一個需要參數的工具（如 `search_todos`）

**如果未連接**：
這一步難以在 binary 測試中可靠執行（AppleScript 執行時間太長）。
建議先將 MCP 加到 Claude Code 再測試。

## 執行步驟

### Phase 1: 確認目標

1. 解析 `$ARGUMENTS` 取得 MCP server 名稱
2. 執行 `claude mcp list` 確認 server 是否已連接

### Phase 2: 根據連線狀態選擇測試模式

**如果已連接**：
1. 呼叫一個 read-only tool 測試基本連線
2. 呼叫一個需要參數的 tool 測試參數傳遞
3. 輸出診斷報告

**如果未連接**：
1. 找到 binary 路徑
2. 測試 binary 是否存在且可執行
3. 測試 initialize 請求
4. 測試 tools/list 請求
5. 建議用戶將 MCP 加到 Claude Code 以進行完整測試

### Phase 3: 輸出診斷報告

```
═══════════════════════════════════════════
MCP Diagnose 報告
═══════════════════════════════════════════

Server: che-things-mcp
連線狀態: ✓ 已連接到 Claude Code
Binary: /path/to/binary

測試結果:
  ✓ 基本連線測試通過
  ✓ get_projects 呼叫成功 (返回 N 個專案)
  ✓ search_todos 呼叫成功

診斷結果: MCP Server 運作正常

═══════════════════════════════════════════
```

## 常見問題診斷

### 問題：MCP Server 未連接

```bash
# 加入 MCP Server
claude mcp add <name> /path/to/binary

# 或編輯 settings.json
~/.claude/settings.json
```

### 問題：Tool 呼叫卡住

可能原因：Event Loop 阻塞

```swift
// 解決：將同步操作移到背景執行緒
try await withCheckedThrowingContinuation { continuation in
    DispatchQueue.global(qos: .userInitiated).async {
        // 同步操作
        continuation.resume(returning: result)
    }
}
```

### 問題：Tool 呼叫返回錯誤

檢查：
1. 參數格式是否正確
2. 底層服務（如 Things 3）是否正在運行
3. 權限設定（Accessibility、Calendar 等）

## 參考資料

- [MCP Debug 完整指南](/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/mcp/docs/MCP_DEBUG_GUIDE.md)
- [AppleScript 本地化開發規範](/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/mcp/docs/APPLESCRIPT_LOCALIZATION.md)
