# スキルカタログ

> 「あのスキル、使えたのか...」を防ぐためのカテゴリ別スキル紹介

---

## 概要

multi-agent-shogun には **70以上のスキル** が用意されている。
本カタログでは、カテゴリ別に代表的なスキルを紹介する。

**スキルの場所**: `skills/` ディレクトリ

---

## カテゴリ一覧

| カテゴリ | 代表スキル | 用途 |
|----------|------------|------|
| [確認系](#確認系) | confirmation-list, risk-matrix | プロジェクト初期の情報整理 |
| [分析系](#分析系) | system-architecture-analyzer, xlsx-analyzer | 資料・システムの分析 |
| [生成系](#生成系) | api-schema-generator, entity-generator-from-spec | コード・設計書の自動生成 |
| [React系](#react系) | react-mui-crud-scaffold, react-layout-template-generator | React UI の雛形生成 |
| [NestJS/Express系](#nestjsexpress系) | nestjs-code-reviewer, express-jwt-auth-scaffold | バックエンド開発支援 |
| [セキュリティ系](#セキュリティ系) | dotnet-security-audit, aspnet-auth-audit | セキュリティ監査 |
| [図面生成系](#図面生成系) | entity-class-diagram-generator, mermaid-sequence-generator | Mermaid図の自動生成 |

---

## 確認系

プロジェクト初期の情報整理・リスク評価に使用。

### confirmation-list
**確認事項一覧作成**

シニアPM視点で、プロジェクトの不明点・確認事項を情報領域別に整理する。

- **使用タイミング**: 新規案件の初期調査後、顧客ミーティング準備
- **出力**: 領域別の把握情報・不明点・不足資料・リスクフラグ

### risk-matrix
**リスクマトリクス作成**

プロジェクトのリスクを「影響度×発生確率」で評価・可視化。

- **使用タイミング**: プロジェクト計画時、リスク管理会議前
- **出力**: リスク一覧とマトリクス図

---

## 分析系

顧客支給資料やシステムの分析に使用。

### system-architecture-analyzer
**システム構成分析**

顧客から提供されたシステム関連資料（連携図PDF、仕様書、画面キャプチャ）を分析し、システム構成・連携関係・データフローを構造化。

- **使用タイミング**: システム移行プロジェクトの初期段階、マルチクラウド構成の可視化
- **入力**: システム連携図PDF、インターフェース仕様書Excel、画面キャプチャ

### xlsx-analyzer
**Excel資料分析**

複雑なExcel資料（複数シート、マクロ付き）を解析し、構造を把握。

- **使用タイミング**: 顧客支給Excelの理解、データ移行仕様の把握

### dependency-analyzer
**依存関係分析**

プロジェクトの依存関係（npm, pip, NuGet等）を分析し、セキュリティリスクや更新状況を把握。

- **使用タイミング**: 技術選定時、セキュリティ監査時

---

## 生成系

設計書・コードの自動生成に使用。

### api-schema-generator
**APIスキーマ自動生成**

テーブル定義（カラム定義書）からJSON Schema（OpenAPI 3.0準拠）とRESTful APIエンドポイント定義を自動生成。

- **使用タイミング**: DBリプレース、レガシーシステムのAPI化、新規API設計
- **入力**: Markdownテーブル、Excel、CREATE TABLE文

### entity-generator-from-spec
**エンティティ自動生成**

テーブル定義書からTypeORM/Prismaエンティティを自動生成。

- **使用タイミング**: 新規DB設計後、既存DBからのエンティティ生成

### typeorm-seeder-generator
**シードデータ生成**

TypeORMエンティティからシードデータ（テスト用ダミーデータ）を自動生成。

- **使用タイミング**: 開発環境構築、E2Eテスト準備

---

## React系

React + MUI (Material-UI) の UI コンポーネント生成に使用。

### react-mui-crud-scaffold
**React MUI CRUD画面自動生成**

API Schema定義から、React + MUIのCRUD画面セット（一覧・詳細・フォーム）を自動生成。

- **使用タイミング**: 新規管理画面の雛形作成、プロトタイプ作成
- **出力**: 型定義、APIサービス、テーブル、フォーム、ページコンポーネント

### react-layout-template-generator
**レイアウトテンプレート生成**

MUIベースのレイアウトコンポーネント（ヘッダー、サイドバー、フッター）を生成。

- **使用タイミング**: 新規プロジェクトのレイアウト構築

### react-file-download
**ファイルダウンロード機能**

React + axiosでのファイルダウンロード実装パターン。

- **使用タイミング**: CSV/Excel/PDFダウンロード機能の実装

---

## NestJS/Express系

バックエンド開発・レビューに使用。

### nestjs-code-reviewer
**NestJSコードレビュー**

NestJSバックエンドプロジェクトのコード品質を6観点（TypeScript型定義、API設計、エラーハンドリング、セキュリティ、DB、コーディング規約）で体系的にレビュー。

- **使用タイミング**: PRレビュー前、品質監査
- **出力**: Grade A/B/C 判定と改善提案

### express-jwt-auth-scaffold
**Express JWT認証雛形**

Express.js + JWT認証の実装テンプレート。

- **使用タイミング**: 新規API開発、認証機能の追加
- **出力**: ミドルウェア、ルーター、ユーザーサービス

### nestjs-file-export
**NestJSファイルエクスポート**

NestJSでのCSV/Excel/PDFエクスポート実装パターン。

- **使用タイミング**: 帳票出力機能の実装

---

## セキュリティ系

.NET / ASP.NET Core アプリケーションのセキュリティ監査に使用。

### dotnet-security-audit
**.NETセキュリティ監査（評価: 19/20）**

ASP.NET Core MVC, Blazor Server/WASM, Web APIプロジェクトの包括的セキュリティ監査。

- **チェック項目**: 認証認可、機密情報管理、ログ設定、セキュリティ設定
- **使用タイミング**: リリース前監査、セキュリティレビュー

### aspnet-auth-audit
**ASP.NET認証監査**

ASP.NET Coreの認証・認可設定を詳細監査。

- **チェック項目**: Cookie設定、JWT設定、CORS設定、CSRF対策

### blazor-security-checker
**Blazorセキュリティチェック**

Blazor Server/WASM固有のセキュリティ問題を検出。

- **チェック項目**: SignalR設定、クライアント側データ処理、認証フロー

### dotnet-secrets-scanner
**機密情報スキャナー**

.NETプロジェクトの機密情報（APIキー、接続文字列、パスワード）漏洩を検出。

- **使用タイミング**: コミット前チェック、CI/CD パイプライン

---

## 図面生成系

Mermaid形式の図面を自動生成。

### entity-class-diagram-generator
**エンティティクラス図生成（評価: 15/20）**

TypeORMエンティティからMermaidクラス図を自動生成。

- **入力**: TypeORM Entity ファイル（`*.entity.ts`）
- **出力**: Mermaidクラス図（`classDiagram` 形式）
- **使用タイミング**: 設計レビュー、ドキュメント自動生成、新規参画者のオンボーディング

### mermaid-sequence-generator
**シーケンス図生成（評価: 15/20）**

APIフロー、認証フロー等のシーケンス図をMermaid形式で生成。

- **出力**: Mermaidシーケンス図（`sequenceDiagram` 形式）
- **使用タイミング**: API設計書作成、処理フローの可視化

---

## 使い方

スキルを使うには、タスク指示に「〇〇スキルを使用せよ」と明記するか、
`/スキル名` コマンドを実行する。

詳細は [skill-usage-guide.md](skill-usage-guide.md) を参照。

---

## 関連ドキュメント

- [スキル使い方ガイド](skill-usage-guide.md) - 具体的な使用方法
- [skills/](../../skills/) - スキル本体
