# スキル frontmatter 標準スキーマ（統一仕様）

> **Version**: 1.0.0
> **制定**: 2026-06-23（cmd_331・将軍）
> **目的**: `.claude/skills/*/SKILL.md` の frontmatter 書式を全件統一し、誤起動・取りこぼし・発見性低下を防ぐ。
> **根拠**: Anthropic 公式 Agent Skills 仕様（必須は `name` + `description` のみ。標準外フィールドは `metadata` 配下に退避）。

---

## 1. 正となる標準スキーマ

```yaml
---
name: <ディレクトリ名と完全一致・kebab-case>
description: "<何をするか> + <いつ使うか>。三人称・具体キーワードを含める。"
user-invocable: true
metadata:
  category: <下記の語彙から1つ>
  version: "x.y.z"
  tags: [keyword1, keyword2, ...]
  # 以下は元から在った場合のみ保持（無ければ書かない）
  author: <作成者>
  created: <YYYY-MM-DD>
  updated: <YYYY-MM-DD>
  parent: <親スキル名>          # 階層スキルのL2等
  related: [<関連スキル名>, ...]
  score: <評価点>               # skill-evaluate 由来の評価情報
  status: <MVP|stable|deprecated>
---
```

### キーの扱い（厳守）

| キー | 必須/任意 | ルール |
|------|----------|--------|
| `name` | **必須** | ディレクトリ名と**完全一致**。kebab-case（小文字・数字・ハイフン）。先頭末尾ハイフン禁止、連続ハイフン禁止。1〜64文字。 |
| `description` | **必須** | 「何をするか」＋「いつ使うか」の両方。三人称。クォートで囲む。既存が「何を」だけなら「いつ使うか」を1文追記。誇張・空虚な表現は禁止。 |
| `user-invocable` | 統一付与 | 全スキルに `true` を付ける。`invocable:` は廃止し `user-invocable:` に統一。 |
| `metadata` | 任意 | 標準外フィールド（version/category/tags/author/created/parent/score 等）は**全てここへネスト**。トップレベルに置かない。 |

---

## 2. category の統一語彙（metadata.category）

大文字小文字のブレを排し、以下の**小文字・スラッシュ区切り**に統一する。スキルの主目的で1つ選ぶ。

| 語彙 | 対象 |
|------|------|
| `analysis` | 解析・調査・可視化（〜-analyzer, 〜-summary） |
| `review` | レビュー・チェック・監査（〜-checker, 〜-reviewer, 〜-audit） |
| `generation` | コード/ドキュメント生成・scaffold（〜-generator, 〜-scaffold） |
| `security` | セキュリティ診断専門（〜-security-audit, 〜-scanner） |
| `design` | 設計フェーズ支援（design-doc-〜, design-review-〜） |
| `migration` | 移行・変換（〜-migration, 〜-converter） |
| `patterns` | 実装パターン集・スニペット（〜-patterns, 〜-hook） |
| `meta` | スキル自体を扱うメタスキル（skill-〜, recovery 等） |

> 複合する場合は主目的を優先（例: `dotnet-security-audit` は `security`）。

---

## 3. 修正パターン別の手順

### パターンA: frontmatter 自体が無い（`# title` で始まる）
→ ファイル冒頭に標準スキーマの frontmatter ブロックを**新規挿入**。
   - `name` = ディレクトリ名。
   - `description` = 本文の概要1〜2文から「何を＋いつ」を要約して作成。
   - `user-invocable: true`。

### パターンB: `---` で始まるが `name` 欠落
→ `name:` をディレクトリ名で追加。`description` を点検し「いつ使うか」を補う。

### パターンC: トップレベルに version/category/tags 等が散在
→ それらを `metadata:` 配下へ移動。category は§2語彙に正規化。

### パターンD: 本文中に `> **Version**:` 等が書かれている
→ frontmatter の `metadata` に移し、本文の重複記述は削除（本文をスッキリさせる）。

### パターンE: `invocable: true`
→ `user-invocable: true` に置換。

---

## 4. やってはいけないこと

- **情報を捨てない**: score/proposer/parent/created 等は metadata に退避。削除するな。
- **description を短絡しない**: 既存の良い説明を削って薄くするな。足りない「いつ使うか」を足す方向で。
- **name をディレクトリ名と違える**: 公式仕様違反。必ず一致させる。
- **本文ロジック（チェック項目・手順・コード例）には触らない**: 今回は frontmatter 整形のみ。中身は変えるな。
- **複数ファイルを並列 Write しない**: 1件ずつ Edit/Write。

---

## 5. 完了条件（各スキル）

- [ ] `name` がディレクトリ名と一致している
- [ ] `description` に「何を」＋「いつ使うか」が含まれる
- [ ] `user-invocable: true` がある
- [ ] 標準外フィールドが全て `metadata:` 配下にある
- [ ] category が §2 の語彙に正規化されている
- [ ] 元の情報（version/author/score等）が失われていない
- [ ] 本文のロジックは無変更

---

## 6. 検証（全件完了後）

```bash
cd ~/multi-agent-shogun/.claude/skills
# name 欠落が 0 件になっていることを確認
for d in */; do
  f="${d}SKILL.md"; [ -f "$f" ] || { echo "NO FILE: $d"; continue; }
  awk '/^---/{c++;next} c==1&&/^name:/{found=1} END{if(!found) print FILENAME}' "$f"
done
# name とディレクトリ名の不一致を検出
for d in */; do
  f="${d}SKILL.md"; [ -f "$f" ] || continue
  nm=$(awk '/^---/{c++;next} c==1&&/^name:/{sub(/^name:[ ]*/,"");print;exit}' "$f")
  [ "$nm" = "${d%/}" ] || echo "MISMATCH: dir=${d%/} name=$nm"
done
```
両コマンドが無出力なら合格。
