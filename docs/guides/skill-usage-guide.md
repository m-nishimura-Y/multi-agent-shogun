# スキル使い方ガイド

> **Version**: 1.0.0
> **Last Updated**: 2026-02-13
> **Author**: 足軽1号（cmd_041）

---

## スキルとは

**スキル**とは、特定のタスクを効率的に実行するための再利用可能な手順書である。

### スキルの特徴

| 特徴 | 説明 |
|------|------|
| **再利用可能** | 同じパターンのタスクを何度でも実行できる |
| **標準化** | 成果物の品質を一定に保てる |
| **時短** | 手順を考える時間を省略できる |
| **知識共有** | ベストプラクティスがチーム全体で共有される |

### スキルの例

- `confirmation-list`: 確認事項一覧を作成
- `api-schema-generator`: API仕様書からスキーマを生成
- `react-mui-crud-scaffold`: React + MUI のCRUD画面雛形を生成
- `nestjs-code-reviewer`: NestJSコードをレビュー

---

## 呼び出し方法

スキルを呼び出す方法は **3つ** ある。

### 方法1: スラッシュコマンド（推奨）

最もシンプルな方法。スキル名の前に `/` をつけて入力する。

```
/confirmation-list
```

**使用例:**
```
/react-mui-crud-scaffold
/api-schema-generator
/nestjs-code-reviewer
```

**メリット:**
- 入力が簡単
- 自動補完が効く場合がある

### 方法2: Skill tool

Claude Code の `Skill` ツールを使用して呼び出す。

```
Skill(skill: "confirmation-list")
```

**引数付きの場合:**
```
Skill(skill: "api-schema-generator", args: "path/to/spec.yaml")
```

**メリット:**
- プログラム的に呼び出せる
- 引数を渡せる

### 方法3: スキルファイルを直接読む

スキルファイルを Read ツールで読み、手順に従って実行する。

```
Read(file_path: "/home/nishimura/multi-agent-shogun/skills/confirmation-list.md")
```

その後、ファイルに記載された「実行手順」に従って作業する。

**メリット:**
- スキルの詳細を確認しながら実行できる
- 手順をカスタマイズできる

---

## skills/ ディレクトリの構造

```
skills/
├── confirmation-list.md        # 単一ファイル形式
├── api-schema-generator.md
├── react-mui-crud-scaffold.md
├── cicd-health-checker/        # ディレクトリ形式
│   └── SKILL.md
├── code-quality-analyzer/
│   └── SKILL.md
└── ...
```

### 2つの形式

| 形式 | 構造 | 例 |
|------|------|-----|
| **単一ファイル** | `skills/スキル名.md` | `confirmation-list.md` |
| **ディレクトリ** | `skills/スキル名/SKILL.md` | `cicd-health-checker/SKILL.md` |

ディレクトリ形式は、追加ファイル（テンプレート等）が必要なスキルに使用される。

### スキルファイルの構造

```markdown
---
description: "スキルの説明"
---

# /スキル名 - タイトル

## 概要
スキルの概要説明

## 使用タイミング
どのような場面で使うか

## 実行手順
1. 手順1
2. 手順2
3. ...

## 出力フォーマット
成果物の形式
```

---

## スキル一覧の確認方法

### 方法1: ファイル一覧を見る

```bash
ls ~/multi-agent-shogun/skills/
```

### 方法2: スキル検索ツールを使う

```bash
~/multi-agent-shogun/bin/search-skills.sh キーワード
```

**使用例:**
```bash
# Reactに関連するスキルを検索
~/multi-agent-shogun/bin/search-skills.sh react

# NestJSに関連するスキルを検索
~/multi-agent-shogun/bin/search-skills.sh nestjs

# セキュリティに関連するスキルを検索
~/multi-agent-shogun/bin/search-skills.sh security
```

### 方法3: カテゴリ別一覧

| カテゴリ | スキル例 |
|----------|----------|
| **確認系** | confirmation-list, risk-matrix |
| **分析系** | system-architecture-analyzer, dependency-analyzer, document-structure-analyzer |
| **生成系** | api-schema-generator, entity-generator-from-spec, nfr-template-generator |
| **React系** | react-mui-crud-scaffold, react-file-download, react-tag-management-ui |
| **NestJS系** | nestjs-code-reviewer, nestjs-file-export, typeorm-seeder-generator |
| **セキュリティ系** | dotnet-security-audit, aspnet-auth-audit, blazor-security-checker |

---

## よくある質問

### Q: どのスキルを使えばいいか分からない

A: `search-skills.sh` でキーワード検索するか、カテゴリ別一覧を参照せよ。

### Q: スキルが見つからない

A: スキル名が正しいか確認せよ。`ls skills/` で一覧を確認できる。

### Q: スキルをカスタマイズしたい

A: 方法3（直接読む）で実行し、手順を適宜調整せよ。

---

## 関連ドキュメント

- [スキル使い方ガイド - カテゴリ別編](skill-usage-categories.md)（足軽2担当）
- [スキル使い方ガイド - 実践例編](skill-usage-examples.md)（足軽3担当）
- [スキル使い方ガイド - FAQ編](skill-usage-faq.md)（足軽4担当）
