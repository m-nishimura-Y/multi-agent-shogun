# MCP 使い方ガイド

> **Version**: 1.1.0
> **Last Updated**: 2026-02-17
> **Author**: 軍師（cmd_022）

---

## 概要

**MCP（Model Context Protocol）** は、Claude Codeが外部ツールやサービスと連携するためのプロトコルである。
MCPサーバーを通じて、Notion、Obsidian、Draw.io等の外部ツールをClaude Codeから直接操作できる。

### MCPツールの使用方法

MCPツールは遅延ロード方式。使用前に必ず `ToolSearch` で検索せよ。

```
例: Notionを使う場合
1. ToolSearch で "notion" を検索
2. 返ってきたツール（mcp__notion__xxx）を使用
```

---

## 導入済みMCP一覧

| MCP | 機能 | 状態 |
|-----|------|------|
| Notion | ノート・データベース操作 | ✅ 稼働中 |
| Playwright | ブラウザ自動操作 | ✅ 稼働中 |
| GitHub | リポジトリ操作 | ✅ 稼働中 |
| Sequential Thinking | 段階的思考 | ✅ 稼働中 |
| Memory | 永続記憶 | ✅ 稼働中 |
| Document-Loader | ドキュメント読み込み | ✅ 稼働中 |
| Codex | AIコーディング支援 | ✅ 稼働中 |
| **Draw.io** | 図面作成・編集 | ✅ 稼働中（v1.0.0追加） |
| **Obsidian** | ノート読み書き・検索 | ✅ 稼働中（v1.0.0追加） |

---

## Draw.io MCP

### 概要

Draw.io図面の作成・編集を行うMCPサーバー。
シーケンス図、フローチャート、ER図等をClaude Codeから直接ブラウザで開ける。

### 🔴 推奨形式: Mermaid

**Mermaid記法を使用することを強く推奨する。** シンプルで再利用しやすい。

### 主要ツール（実際に使用するもの）

| ツール | 説明 | 推奨度 |
|--------|------|--------|
| `mcp__drawio__open_drawio_mermaid` | **Mermaid記法で図を開く** | ⭐⭐⭐ 推奨 |
| `mcp__drawio__open_drawio_csv` | CSV形式で図を開く | ⭐⭐ |
| `mcp__drawio__open_drawio_xml` | XML形式で図を開く | ⭐ |

### 運用フロー

```
1. MCPでMermaid記法を渡す
   ↓
2. ブラウザでDraw.ioエディタが自動で開く
   ↓
3. 必要に応じて編集・調整
   ↓
4. .mmd ファイルとして docs/diagrams/ に保存（再利用可能）
   ↓
5. 必要ならブラウザからエクスポート（PNG, SVG等）
```

### 使用例（動作確認済み）

#### 例1: シーケンス図の作成（推奨）

```
mcp__drawio__open_drawio_mermaid(
  content: """
sequenceDiagram
    autonumber
    participant C as Client
    participant S as Server
    C->>S: リクエスト
    S-->>C: レスポンス
"""
)
```

#### 例2: フローチャートの作成

```
mcp__drawio__open_drawio_mermaid(
  content: "flowchart TD\n  A[開始] --> B{条件}\n  B -->|Yes| C[処理A]\n  B -->|No| D[処理B]"
)
```

#### 例3: クラス図の作成

```
mcp__drawio__open_drawio_mermaid(
  content: """
classDiagram
    class User {
        +String name
        +String email
        +login()
    }
"""
)
```

### .mmd ファイル運用ルール

| 項目 | ルール |
|------|--------|
| **保存先** | `docs/diagrams/` |
| **命名規則** | `{プロジェクト名}-{図の種類}.mmd` |
| **例** | `arms-mock-auth-login.mmd`, `organization-flow.mmd` |
| **ヘッダー** | `%%{ init: { "theme": "default" } }%%` を先頭に追加推奨 |

### 作成済み図面

| ファイル | 内容 |
|----------|------|
| `arms-mock-auth-login.mmd` | 認証フロー（ログイン） |
| `arms-mock-auth-api-call.mmd` | 認証済みAPI呼び出しフロー |
| `arms-mock-export.mmd` | 原稿エクスポートフロー |
| `arms-mock-logout.mmd` | ログアウトフロー |
| `organization-flow.mmd` | 組織フロー |

### トラブルシューティング

| 問題 | 対処法 |
|------|--------|
| ブラウザが開かない | ツールが正しくロードされているか確認 |
| 図が表示されない | Mermaid記法の構文エラーを確認 |
| ツールが見つからない | `ToolSearch(query: "drawio")` で再検索 |

---

## Obsidian MCP

### 概要

Obsidianノートの読み書き・検索を行うMCPサーバー。
ナレッジベースへのアクセス、議事録作成、メモ検索等をClaude Codeから直接実行できる。

### 使用方法

1. **ToolSearch** で `obsidian` を検索してツールをロード
2. **Obsidianアプリが起動している状態** で使用
3. **Local REST API プラグイン** が有効化されていること

### 主要ツール

| ツール | 説明 |
|--------|------|
| `mcp__obsidian__obsidian_list_notes` | ノート一覧を取得（ディレクトリツリー表示） |
| `mcp__obsidian__obsidian_read_note` | ノートを読み取り |
| `mcp__obsidian__obsidian_update_note` | ノートを書き込み（作成・更新）※wholeFileモード |
| `mcp__obsidian__obsidian_global_search` | ノートを全文検索 |
| `mcp__obsidian__obsidian_delete_note` | ノートを削除 |
| `mcp__obsidian__obsidian_search_replace` | ノート内の文字列置換 |
| `mcp__obsidian__obsidian_manage_frontmatter` | frontmatterのget/set/delete |
| `mcp__obsidian__obsidian_manage_tags` | タグの追加・削除・一覧 |

### 使用例

#### 例1: ノート一覧の取得

```
mcp__obsidian__obsidian_list_notes(
  dirPath: "Projects"
)
→ Projects フォルダ以下のノート一覧がツリー形式で返される
```

#### 例2: ノートの読み取り

```
mcp__obsidian__obsidian_read_note(
  filePath: "Projects/multi-agent-shogun/memo.md"
)
```

#### 例3: ノートの作成・更新

```
mcp__obsidian__obsidian_update_note(
  targetType: "filePath",
  targetIdentifier: "Projects/multi-agent-shogun/meeting-notes/2026-02-17.md",
  modificationType: "wholeFile",
  wholeFileMode: "overwrite",
  createIfNeeded: true,
  overwriteIfExists: true,
  content: "# 会議メモ\n\n## 議題\n- 項目1\n- 項目2"
)
```

#### 例4: ノートの全文検索

```
mcp__obsidian__obsidian_global_search(
  query: "multi-agent"
)
→ 検索にマッチするノート一覧とマッチ箇所が返される
```

#### 例5: frontmatter の操作

```
# frontmatter のキーを取得
mcp__obsidian__obsidian_manage_frontmatter(
  filePath: "Projects/note.md",
  operation: "get",
  key: "tags"
)

# frontmatter のキーを設定
mcp__obsidian__obsidian_manage_frontmatter(
  filePath: "Projects/note.md",
  operation: "set",
  key: "status",
  value: "completed"
)
```

#### 例6: タグの管理

```
mcp__obsidian__obsidian_manage_tags(
  filePath: "Projects/note.md",
  operation: "add",
  tags: ["project", "2026"]
)
```

### 前提条件

| 条件 | 説明 |
|------|------|
| Obsidianアプリ | Obsidianが起動していること |
| Local REST API | 「Local REST API」プラグインがインストール・有効化されていること |
| APIキー | プラグイン設定でAPIキーが設定されていること |

### プラグイン設定

1. Obsidian設定 → コミュニティプラグイン → 「Local REST API」を検索・インストール
2. プラグインを有効化
3. プラグイン設定でAPIキーを確認・設定

### トラブルシューティング

| 問題 | 対処法 |
|------|--------|
| 接続できない | Obsidianが起動しているか確認。プラグインが有効か確認。 |
| 認証エラー | APIキーが正しく設定されているか確認 |
| ノートが見つからない | パスが正しいか確認。`obsidian_list_notes` で一覧を取得して確認 |
| ツールが見つからない | `ToolSearch(query: "obsidian")` で再検索 |

### 関連スキル

Obsidian MCP と連携して使用できるスキルがある。

| スキル | 説明 | 用途 |
|--------|------|------|
| **obsidian-auto-register** | 品質ゲートキーパー付きノート登録 | 重複チェック・frontmatter自動付与 |
| **obsidian-note-creator** | テンプレートベースのノート作成 | 定型フォーマットのノート作成 |

#### obsidian-auto-register

**概要**: 新規ノートを Obsidian に登録する前に、重複チェックと品質検証を行うスキル。

**特徴**:
- 既存ノートとの重複チェック（タイトル・内容の類似度判定）
- frontmatter の自動付与（created, tags, source 等）
- カテゴリ別の保存先自動判定

**使用例**:
```
/obsidian-auto-register
タイトル: セキュリティ診断結果
内容: ...
カテゴリ: 診断レポート
```

#### obsidian-note-creator

**概要**: テンプレートを使用して定型フォーマットのノートを作成するスキル。

**対応テンプレート**:
- `meeting-notes`: 会議メモ
- `project-summary`: プロジェクトサマリ
- `decision-log`: 意思決定ログ
- `knowledge-base`: ナレッジベース記事

**使用例**:
```
/obsidian-note-creator
テンプレート: meeting-notes
タイトル: 2026-02-17 定例会議
参加者: A, B, C
```

### MCP vs スキルの使い分け

| 用途 | 推奨 |
|------|------|
| 単純なノート読み書き | **MCP** (`mcp__obsidian__obsidian_*`) |
| 定型フォーマットのノート作成 | **obsidian-note-creator** |
| 品質チェック付きの登録 | **obsidian-auto-register** |
| 全文検索・一覧取得 | **MCP** (`obsidian_global_search`, `obsidian_list_notes`) |
| frontmatter操作 | **MCP** (`obsidian_manage_frontmatter`) |
| タグ管理 | **MCP** (`obsidian_manage_tags`) |

---

## 他のMCPガイド

| MCP | ガイド |
|-----|--------|
| Codex MCP | [codex-mcp-guide.md](./codex-mcp-guide.md) |

---

## 関連ドキュメント

- [CLAUDE.md](../../CLAUDE.md) - システム全体構成
- [docs/tools.md](../tools.md) - binツール一覧
