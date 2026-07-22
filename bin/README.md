# bin/ ツール一覧

multi-agent-shogun で使用するシェルスクリプト集。

---

## ⚠️ 使用者早見表（重要）

| スクリプト | 使用者 | 用途 |
|-----------|--------|------|
| **restart-agents.sh** | 🚫 殿専用 | 他のエージェントを再起動（MCP設定変更後など） |
| **self-compact.sh** | ✅ エージェント自身 | 自分をコンパクション（残量15%以下で使用） |
| **notify.sh** | ✅ 全員 | 他のエージェントに通知を送る |
| **recovery.sh** | 🔧 システム | SessionStart hook から自動呼び出し |
| **search-skills.sh** | ✅ 全員 | スキル検索 |

**注意**: `restart-agents.sh` を足軽が実行すると、他の足軽全員が再起動されてしまう！

---

## エージェント管理

### restart-agents.sh
**🚫 殿専用 - 他のエージェントを再起動**

エージェントを `/exit` → `claude --permission-mode auto` → `/recovery` の順で再起動する。

```bash
# 足軽全員（1-8）
~/multi-agent-shogun/bin/restart-agents.sh ashigaru

# 本隊のみ（1-4）
~/multi-agent-shogun/bin/restart-agents.sh hontai

# 別働隊のみ（5-8）
~/multi-agent-shogun/bin/restart-agents.sh betsudoutai

# 全軍（足軽+軍師+家老）
~/multi-agent-shogun/bin/restart-agents.sh all

# 確認スキップ（-f）
~/multi-agent-shogun/bin/restart-agents.sh ashigaru -f

# 個別指定
~/multi-agent-shogun/bin/restart-agents.sh ashigaru1 ashigaru5
```

### notify.sh
**エージェント間通知**

tmux send-keys + Enter を確実に実行する。エイリアス対応。

```bash
# 家老に通知
~/multi-agent-shogun/bin/notify.sh karo '【cmd_XXX】タスクを実行せよ'

# 足軽5に通知（短縮形）
~/multi-agent-shogun/bin/notify.sh a5 '任務完了を報告せよ'

# 軍師に通知
~/multi-agent-shogun/bin/notify.sh gunshi '別働隊の状況を報告せよ'
```

**エイリアス一覧**:
| エイリアス | ペイン |
|-----------|--------|
| shogun | shogun:0 |
| gunshi | gunshi:0 |
| bugyo | bugyo:0 |
| karo | multiagent:0.0 |
| ashigaru1 (a1) | multiagent:0.1 |
| ashigaru2 (a2) | multiagent:0.2 |
| ... | ... |
| ashigaru8 (a8) | multiagent:0.8 |

### self-compact.sh
**✅ エージェント自身が使用 - 自己コンパクション実行**

コンテキスト残量が15%以下のとき、自分のペインに `/compact` を送信する。

**足軽がコンパクションしたい時はこれを使え！**（restart-agents.sh ではない）

```bash
~/multi-agent-shogun/bin/self-compact.sh
```

### recovery.sh
**コンパクション復帰支援**

`/recovery` スキルのバックエンド。セッション名から役割を判定し、適切な指示書を読み込む。

---

## スキル関連

### search-skills.sh
**スキル検索**

キーワードでスキルを検索する。

```bash
# セキュリティ関連スキルを検索
~/multi-agent-shogun/bin/search-skills.sh security

# React関連スキルを検索
~/multi-agent-shogun/bin/search-skills.sh react
```

---

## 状態確認・同期

### status.sh
**全軍状態確認**

各エージェントの稼働状況を確認する。

```bash
~/multi-agent-shogun/bin/status.sh
```

### check-stale-workers.sh
**停滞ワーカー検出**

長時間応答のない足軽を検出する。

```bash
~/multi-agent-shogun/bin/check-stale-workers.sh
```

### sync-dashboard.sh
**ダッシュボード同期**

各種ステータスファイルから dashboard.md を更新する。

```bash
~/multi-agent-shogun/bin/sync-dashboard.sh
```

---

## 進捗管理

### update-progress.sh
**進捗更新**

タスクの進捗状況を更新する。

```bash
~/multi-agent-shogun/bin/update-progress.sh
```

### update-build-status.sh
**ビルドステータス更新**

CI/CDのビルド結果を反映する。

```bash
~/multi-agent-shogun/bin/update-build-status.sh
```

---

## レポート

### generate-report.sh
**レポート生成**

完了タスクのサマリレポートを生成する。

```bash
~/multi-agent-shogun/bin/generate-report.sh
```

---

## ヘルプの見方

各スクリプトは `--help` オプションに対応している（一部除く）。

```bash
~/multi-agent-shogun/bin/restart-agents.sh --help
~/multi-agent-shogun/bin/notify.sh
```
