# スキル逆引き表

> **Version**: 1.0.0
> **Created**: 2026-03-05
> **Purpose**: 「このタスクにはこのスキル」を即座に判断するための逆引き表

## 使い方

1. **タスク種別**から該当セクションを探す
2. **推奨スキル**を確認
3. タスク指示書に `recommended_skills:` として記載

---

## クイックリファレンス（よく使うパターン）

| タスク種別 | 第一推奨 | 第二推奨 |
|-----------|---------|---------|
| NestJS API追加 | `api-endpoint-scaffold` | `nestjs-route-order-checker` |
| React CRUD画面 | `react-mui-crud-scaffold` | `react-code-review-checklist` |
| セキュリティ診断 | `security-audit-orchestrator` | （技術別スキルを自動選択）|
| 設計書レビュー | `design-doc-consistency-checker` | `design-doc-terminology-checker` |
| FE/BE整合性確認 | `fe-be-consistency-checker` | `enum-consistency-checker` |
| Prisma変更 | `prisma-schema-analyzer` | `prisma-migration-conflict-checker` |

---

## NestJS / バックエンド

### API追加・CRUD実装

| スキル | いつ使う |
|--------|---------|
| `api-endpoint-scaffold` | Controller + Service + DTO をセット生成 |
| `nestjs-route-order-checker` | 静的/動的ルート順序の問題検出 |
| `nestjs-code-reviewer` | 実装後の品質レビュー（6観点） |
| `prisma7-nestjs-service-generator` | Prisma 7 向け PrismaService 生成 |

### ファイル出力

| スキル | いつ使う |
|--------|---------|
| `nestjs-file-export` | Excel/CSV/タブ区切りエクスポート |
| `nestjs-pdf-export-service` | PDF帳票生成（pdfkit） |
| `zengin-fb-format-generator` | 全銀協フォーマットFBデータ生成 |

---

## React / フロントエンド

### 画面生成

| スキル | いつ使う |
|--------|---------|
| `react-mui-crud-scaffold` | API Schemaから一覧・詳細・フォーム生成 |
| `image-management-page-generator` | 商品画像管理ページ |
| `multi-tab-master-page-generator` | タブ切り替えマスタ管理 |
| `react-tag-management-ui` | タグ/ラベル管理UI |
| `react-layout-template-generator` | レイアウトテンプレート |

### 実装パターン

| スキル | いつ使う |
|--------|---------|
| `react-bulk-action-hook` | 一括選択・一括処理フック |
| `react-file-download` | ファイルダウンロード実装 |
| `react-undefined-guard-pattern` | undefined エラー防止パターン |
| `useEffect-loading-guard` | ローディング制御パターン |

### レビュー

| スキル | いつ使う |
|--------|---------|
| `react-code-review-checklist` | React/TS コード品質レビュー |

---

## Prisma / データベース

| スキル | いつ使う |
|--------|---------|
| `prisma-schema-analyzer` | スキーマ・設定・マイグレーション解析 |
| `prisma-migration-conflict-checker` | 並列開発でのコンフリクト事前検出 |
| `prisma-design-doc-diff-checker` | schema.prisma と設計書の差分検出 |
| `prisma-enum-extender` | enum拡張時のRecord使用箇所検出 |
| `prisma-dto-type-mapper` | enum⇔DTO string 型変換検出 |
| `prisma-where-builder` | where条件の型安全組み立て |
| `entity-generator-from-spec` | テーブル定義書からEntity生成 |

---

## FE/BE 整合性

| スキル | いつ使う |
|--------|---------|
| `fe-be-consistency-checker` | API整合性チェック（環境変数、型、エンドポイント）|
| `fe-be-response-mapper` | BE→FE型変換関数生成 |
| `enum-consistency-checker` | FE型/BE DTO/Prisma enum 3層整合性 |
| `api-call-site-finder` | APIエンドポイント呼び出し箇所検出 |
| `api-response-case-converter` | snake_case⇔camelCase変換 |

---

## 設計書

### レビュー・検証

| スキル | いつ使う |
|--------|---------|
| `design-doc-consistency-checker` | 設計書間のデータ定義・状態遷移整合性 |
| `design-doc-terminology-checker` | 用語定義の統一性チェック |
| `design-doc-cross-reference-checker` | 参照リンク切れ検出 |
| `design-doc-quality-reviewer` | 品質レビュー（4観点・Grade判定）|
| `design-doc-security-reviewer` | セキュリティ要件網羅性チェック |
| `design-doc-version-diff` | バージョン間差分抽出 |

### API設計

| スキル | いつ使う |
|--------|---------|
| `api-design-doc-diff-checker` | API設計書と実装コードの差分検出 |
| `api-design-readiness-checker` | API設計に必要な情報の充足度調査 |
| `api-schema-generator` | テーブル定義からJSON Schema生成 |

### 外部連携

| スキル | いつ使う |
|--------|---------|
| `external-system-integration-reviewer` | 外部システム連携整合性レビュー |

---

## セキュリティ診断

### オーケストレーター（最初に使う）

| スキル | いつ使う |
|--------|---------|
| `security-audit-orchestrator` | 技術スタック自動検出→適切なスキル選択 |

### 技術別診断

| スキル | 対象技術 |
|--------|---------|
| `express-security-audit` | Express.js / Node.js |
| `fastapi-security-audit` | FastAPI / Python |
| `dotnet-security-audit` | ASP.NET Core |
| `aspnet-auth-audit` | ASP.NET Core 認証・認可 |
| `blazor-security-checker` | Blazor Server/WASM |
| `gcp-iap-auth-audit` | GCP IAP認証 |

### 特定脆弱性

| スキル | いつ使う |
|--------|---------|
| `dotnet-process-injection-audit` | コマンドインジェクション検出 |
| `dotnet-secrets-scanner` | 機密情報スキャン |
| `windows-credential-audit` | Windows認証情報管理 |
| `express-logging-auditor` | ログ・監査設定診断 |
| `security-audit-checker-v2` | CSRF/SQLi/廃止関数検出 |

---

## GCP

| スキル | いつ使う |
|--------|---------|
| `gcp-config-analyzer` | GCP関連設定の自動解析 |
| `gcp-cloudrun-analyzer` | Cloud Run構成解析 |
| `gcp-cloudrun-scaffolder` | Cloud Runデプロイファイル生成 |
| `gcp-cloudbuild-auditor` | Cloud Build設定監査 |

---

## プロジェクト分析

| スキル | いつ使う |
|--------|---------|
| `code-quality-analyzer` | TS/JSコード品質スコア（A+〜D）|
| `fullstack-architecture-analyzer` | Vue/React + Express/NestJS構成解析 |
| `typescript-fullstack-analyzer` | TSフルスタック構成解析 |
| `cicd-health-checker` | CI/CD設定のEOL・セキュリティチェック |
| `repo-test-status-checker` | テスト整備状況チェック |
| `dotnet-project-summary` | .NETプロジェクト概要抽出 |
| `dotnet-architecture-analyzer` | .NETアーキテクチャ詳細解析 |
| `dotnet-test-analyzer` | .NETテスト状況解析 |
| `laravel-architecture-analyzer` | Laravelアーキテクチャ解析 |
| `php-laravel-quality-analyzer` | PHP/Laravelコード品質評価 |
| `python-code-quality-analyzer` | Pythonコード品質評価 |

---

## ドキュメント・図面

| スキル | いつ使う |
|--------|---------|
| `mermaid-sequence-generator` | APIフローをMermaidシーケンス図に |
| `entity-class-diagram-generator` | TypeORMエンティティからクラス図 |
| `document-structure-analyzer` | 複数形式文書の一括分析 |
| `docx-meeting-analyzer` | 議事録から合意事項・宿題抽出 |
| `pdf-business-doc-analyzer` | PDF提案書・RFP解析 |
| `pptx-ui-extractor` | PowerPointから画面キャプチャ抽出 |
| `xlsx-analyzer` | Excel解析（ライブラリ不要）|

---

## 提案・見積

| スキル | いつ使う |
|--------|---------|
| `proposal-summary` | プロジェクトサマリー作成 |
| `cost-breakdown` | 開発費用分解表 |
| `risk-matrix` | リスク・懸念点整理 |
| `confirmation-list` | 確認事項一覧作成 |
| `nfr-template-generator` | 非機能要件一覧生成（ISO 25010） |
| `functional-requirements-generator` | 機能要件一覧生成 |
| `tech-stack-proposal-generator` | 技術スタック提案書生成 |
| `rbac-design-generator` | RBAC設計書生成 |
| `data-volume-estimator` | データ量見積 |
| `feasibility-assessment-aggregator` | 実現可否判定統合 |
| `gap-analysis-integrator` | 情報充足度調査結果統合 |
| `enterprise-dependency-analyzer` | ベンダー依存分析 |
| `system-architecture-analyzer` | システム連携図分析 |

---

## 組織・メタスキル

| スキル | いつ使う |
|--------|---------|
| `recovery` | コンパクション復帰時 |
| `skill-evaluate` | スキル候補の評価（軍師用） |
| `skill-creator` | 新規スキル作成 |
| `skill-catalog-generator` | スキルカタログ更新 |
| `skill-workflow-guide` | スキル組み合わせパターン参照 |
| `mcp-health-checker` | MCP接続ヘルスチェック |
| `mcp-server-installer` | MCPサーバー導入ガイド |
| `obsidian-auto-register` | Obsidian知見登録 |
| `obsidian-note-creator` | Obsidianノート生成 |

---

## その他ユーティリティ

| スキル | いつ使う |
|--------|---------|
| `notes-field-parser` | 備考欄に[KEY]value形式でメタデータ埋め込み |
| `csv-jp-encoding-detector` | 日本語CSVエンコーディング検出 |
| `multi-file-consistency-checker` | 複数ファイル間整合性チェック |
| `close-issues` | GitHub Issue一括クローズ |
| `feature-branch` | フィーチャーブランチ作成 |
| `merge-conflict` | マージコンフリクト解決支援 |
| `pr-self-review` | PRセルフレビュー |

---

## 判断フローチャート

```
タスク内容を確認
    │
    ├─ 新規ファイル3つ以上？
    │   └─ Yes → scaffold系（api-endpoint-scaffold, react-mui-crud-scaffold）
    │
    ├─ 1ファイル修正？
    │   └─ Yes → スキル不要、既存コード参照
    │
    ├─ レビュー系タスク？
    │   └─ Yes → reviewer/checker系
    │
    ├─ セキュリティ診断？
    │   └─ Yes → security-audit-orchestrator
    │
    ├─ 設計書作業？
    │   └─ Yes → design-doc-*系
    │
    └─ その他
        └─ bin/search-skills.sh キーワード で検索
```

---

## 更新履歴

| 日付 | バージョン | 変更内容 |
|------|-----------|---------|
| 2026-03-05 | 1.0.0 | 初版作成（session_012の結果を反映）|
