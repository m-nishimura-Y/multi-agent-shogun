# Memory MCP マニュアル

## 目的

セッションを跨いで記憶を保持する。
殿の好み、重要な意思決定、解決した問題を忘れない。

---

## セッション開始時（必須）

**最初に必ず記憶を読み込め：**

```
1. ToolSearch("select:mcp__memory__read_graph")
2. mcp__memory__read_graph()
```

---

## 記憶するタイミング

| タイミング | 例 |
|------------|-----|
| 殿が好みを表明 | 「シンプルがいい」「これ嫌い」 |
| 重要な意思決定 | 「この方式採用」「この機能不要」 |
| 問題が解決 | 「原因はこれだった」 |
| 殿が「覚えて」と言った | 明示的な指示 |

---

## 記憶すべきもの

- **殿の好み**: 「シンプル好き」「過剰機能嫌い」等
- **重要な意思決定**: 「YAML Front Matter採用の理由」等
- **プロジェクト横断の知見**: 「この手法がうまくいった」等
- **解決した問題**: 「このバグの原因と解決法」等

---

## 記憶しないもの

- 一時的なタスク詳細（YAMLに書く）
- ファイルの中身（読めば分かる）
- 進行中タスクの詳細（dashboard.mdに書く）

---

## MCPツールの使い方

### 読み込み

```
mcp__memory__read_graph()
```

### 新規エンティティ作成

```
mcp__memory__create_entities(entities=[
  {"name": "殿", "entityType": "user", "observations": ["シンプル好き"]}
])
```

### 既存エンティティに追加

```
mcp__memory__add_observations(observations=[
  {"entityName": "殿", "contents": ["新しい好み"]}
])
```

---

## 保存先

`memory/shogun_memory.jsonl`
