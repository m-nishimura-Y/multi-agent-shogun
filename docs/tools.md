# bin/ ツール一覧

> **Last Updated**: 2026-02-09
> **作成**: 足軽3号（cmd_046）

multi-agent-shogun システムで使用するツールの一覧。

---

## 足軽向けツール

### notify.sh

エージェント間通知を確実に送信する。

| 項目 | 内容 |
|------|------|
| 用途 | tmux send-keys + Enter を確実に実行（Enter忘れ防止） |
| 対象ユーザー | **足軽**（全員必須） |
| 場所 | `~/multi-agent-shogun/bin/notify.sh` |

**使用例:**

```bash
# 本隊（足軽1-4）→ 家老
~/multi-agent-shogun/bin/notify.sh karo 'ashigaru1、任務完了でござる。'
~/multi-agent-shogun/bin/notify.sh multiagent:0.0 'メッセージ'

# 別働隊（足軽5-8）→ 軍師
~/multi-agent-shogun/bin/notify.sh gunshi 'ashigaru5、報告書を確認されよ。'

# 短縮形も使用可
~/multi-agent-shogun/bin/notify.sh a1 'メッセージ'  # ashigaru1へ
```

**エイリアス対応:**

| エイリアス | 実際のペイン |
|------------|--------------|
| shogun | shogun:0 |
| gunshi | gunshi:0 |
| karo | multiagent:0.0 |
| ashigaru1 / a1 | multiagent:0.1 |
| ashigaru5 / a5 | multiagent:0.5 |

**注意事項:**
- 直接 `tmux send-keys` を使わず、必ずこのスクリプトを使用せよ
- Enter忘れによる通知未達を防止

---

### update-progress.sh

足軽の進捗を progress.yaml に自動更新する。

| 項目 | 内容 |
|------|------|
| 用途 | 進捗率とタスク情報を progress.yaml に記録 |
| 対象ユーザー | **足軽**（推奨） |
| 場所 | `~/multi-agent-shogun/bin/update-progress.sh` |

**使用例:**

```bash
# 基本構文
~/multi-agent-shogun/bin/update-progress.sh <足軽番号> <進捗率> [タスク概要]

# タスク開始（50%進捗）
~/multi-agent-shogun/bin/update-progress.sh 3 50 "cmd_046実装中"

# タスク完了（自動リセット）
~/multi-agent-shogun/bin/update-progress.sh 3 100 "cmd_046完了"

# 待機中にリセット
~/multi-agent-shogun/bin/update-progress.sh 3 0
```

**引数:**

| 引数 | 必須 | 説明 |
|------|------|------|
| 足軽番号 | ○ | 1-8 |
| 進捗率 | ○ | 0-100（100で完了、自動リセット） |
| タスク概要 | △ | current_task に設定される |

**注意事項:**
- 100%指定時は自動でリセット（current_task=null, progress=0）
- タイムスタンプ・last_updated も自動更新

---

### search-skills.sh

スキル一覧の検索・表示により重複作成を防止する。

| 項目 | 内容 |
|------|------|
| 用途 | skills/ ディレクトリ内のスキルを検索 |
| 対象ユーザー | **足軽**（スキル作成前に確認推奨） |
| 場所 | `~/multi-agent-shogun/bin/search-skills.sh` |

**使用例:**

```bash
# キーワード検索
~/multi-agent-shogun/bin/search-skills.sh react

# 全スキル一覧
~/multi-agent-shogun/bin/search-skills.sh --list

# 詳細付き一覧
~/multi-agent-shogun/bin/search-skills.sh --list --verbose

# カテゴリ別一覧
~/multi-agent-shogun/bin/search-skills.sh --category

# 複数キーワード（AND検索）
~/multi-agent-shogun/bin/search-skills.sh "react mui"

# ヘルプ
~/multi-agent-shogun/bin/search-skills.sh --help
```

**オプション:**

| オプション | 説明 |
|------------|------|
| --list, -l | 全スキル一覧表示 |
| --verbose, -v | 詳細情報表示（--listと併用） |
| --category, -c | カテゴリ別一覧 |
| --count | スキル数のみ表示 |
| --help, -h | ヘルプ表示 |

---

### update-build-status.sh

FE/BEのビルド状況を全軍で共有する。

| 項目 | 内容 |
|------|------|
| 用途 | ビルドステータスの共有・作業中モジュールの登録 |
| 対象ユーザー | **足軽**（コンフリクト防止に推奨） |
| 場所 | `~/multi-agent-shogun/bin/update-build-status.sh` |
| ステータスファイル | `status/build_status.yaml` |

**使用例:**

```bash
# 現在のステータス確認
~/multi-agent-shogun/bin/update-build-status.sh status

# ビルドステータス更新
~/multi-agent-shogun/bin/update-build-status.sh frontend ok
~/multi-agent-shogun/bin/update-build-status.sh frontend error "Module not found: xxx"
~/multi-agent-shogun/bin/update-build-status.sh backend building

# 作業中モジュール登録（コンフリクト防止）
~/multi-agent-shogun/bin/update-build-status.sh working ashigaru2 "frontend/src/pages/ProductListPage.tsx"

# 作業完了
~/multi-agent-shogun/bin/update-build-status.sh done ashigaru2

# エラー対応担当割り当て
~/multi-agent-shogun/bin/update-build-status.sh assign frontend ashigaru3
```

**コマンド一覧:**

| コマンド | 引数 | 説明 |
|----------|------|------|
| status | なし | 現在のビルドステータスを表示 |
| frontend/backend | ok\|error\|building [message] | ステータス更新 |
| working | worker module | 作業中モジュールを登録 |
| done | worker | 作業完了を登録 |
| assign | target worker | エラー対応担当を割り当て |

**推奨ワークフロー:**
1. ファイル編集前: `working ashigaru2 "path/to/file.tsx"` で登録
2. ビルドエラー発生時: `frontend error "エラーメッセージ"` で全軍に共有
3. 修正完了時: `frontend ok` + `done ashigaru2` で更新

---

## 家老・軍師向けツール

### sync-dashboard.sh

progress.yaml の内容を dashboard.md の「全軍ステータス」に反映する。

| 項目 | 内容 |
|------|------|
| 用途 | 本隊/別働隊の作業状況を dashboard.md に自動反映 |
| 対象ユーザー | **家老・軍師** |
| 場所 | `~/multi-agent-shogun/bin/sync-dashboard.sh` |

**使用例:**

```bash
~/multi-agent-shogun/bin/sync-dashboard.sh
```

**機能:**
1. queue/progress.yaml を読み取り
2. 本隊/別働隊の作業状況を集計
3. dashboard.md の「🏯 全軍ステータス」セクションを更新
4. 最終更新時刻を更新

**注意事項:**
- 冪等性あり（何度実行しても同じ結果）
- 足軽は通常使用しない（家老・軍師が管理）

---

### check-stale-workers.sh

長時間更新がない足軽に自動確認メッセージを送信する。

| 項目 | 内容 |
|------|------|
| 用途 | progress.yaml を監視し、一定時間更新がない足軽に確認 |
| 対象ユーザー | **家老・軍師** |
| 場所 | `~/multi-agent-shogun/bin/check-stale-workers.sh` |

**使用例:**

```bash
# デフォルト（30分以上更新なし）
~/multi-agent-shogun/bin/check-stale-workers.sh

# 60分以上更新なし
~/multi-agent-shogun/bin/check-stale-workers.sh 60

# 15分以上更新なし
~/multi-agent-shogun/bin/check-stale-workers.sh 15

# ヘルプ
~/multi-agent-shogun/bin/check-stale-workers.sh --help
```

**動作:**
1. progress.yaml から各足軽の updated_at を取得
2. 閾値を超過した作業中の足軽を検出
3. notify.sh で確認メッセージを送信

**注意事項:**
- 待機中（current_task: null）の足軽はスキップ
- 本隊は家老、別働隊は軍師が管理

---

## 全員向けツール

### status.sh

全エージェントの状態を一覧表示する。

| 項目 | 内容 |
|------|------|
| 用途 | 各エージェントの状態（idle/working/STUCK）を表示 |
| 対象ユーザー | **全員**（状況確認用） |
| 場所 | `~/multi-agent-shogun/bin/status.sh` |

**使用例:**

```bash
~/multi-agent-shogun/bin/status.sh
```

**出力例:**

```
==============================================
 Multi-Agent Shogun - Status Dashboard
 2026-02-09 12:00:00
==============================================

AGENT        PANE               STATUS
----------------------------------------------
shogun       shogun:0           idle
karo         multiagent:0.0     working
gunshi       gunshi:0           idle
ashigaru1    multiagent:0.1     idle
...
```

**ステータス凡例:**

| ステータス | 意味 |
|------------|------|
| idle | プロンプト待ち（入力可能） |
| working | 処理中（thinking, Effecting等） |
| STUCK | メッセージ残存（要確認：Enter未送信の可能性） |
| OFFLINE | セッション未起動 |

---

## ツール一覧サマリ

| ツール | 用途 | 対象 |
|--------|------|------|
| notify.sh | エージェント間通知 | 足軽（必須） |
| update-progress.sh | 進捗更新 | 足軽（推奨） |
| search-skills.sh | スキル検索 | 足軽 |
| update-build-status.sh | ビルドステータス共有 | 足軽（推奨） |
| sync-dashboard.sh | dashboard連動 | 家老・軍師 |
| check-stale-workers.sh | 長時間更新なし確認 | 家老・軍師 |
| status.sh | 全エージェント状態表示 | 全員 |

---

## 関連ドキュメント

- [instructions/ashigaru.md](../instructions/ashigaru.md) - 足軽向け詳細説明
- [instructions/karo.md](../instructions/karo.md) - 家老向け説明
- [instructions/gunshi.md](../instructions/gunshi.md) - 軍師向け説明
