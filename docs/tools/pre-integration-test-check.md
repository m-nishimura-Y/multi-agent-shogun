# 統合テスト前チェックスクリプト

## 概要

統合テスト実行前に確認すべき事項を自動チェックするスクリプト。

## 使用方法

```bash
# 基本使用法
~/multi-agent-shogun/bin/pre-integration-test-check.sh /path/to/project

# S-automation の場合
~/multi-agent-shogun/bin/pre-integration-test-check.sh ~/projects/s-automation

# 詳細モード
~/multi-agent-shogun/bin/pre-integration-test-check.sh ~/projects/s-automation --verbose
```

## チェック項目

| No | カテゴリ | チェック内容 |
|----|----------|--------------|
| 1 | FE ビルド | node_modules存在、dist/存在、buildスクリプト定義 |
| 2 | BE ビルド | node_modules存在、dist/存在、Prisma Client生成 |
| 3 | BE 起動 | NestJSプロセス稼働、ヘルスチェック応答 |
| 4 | DB 接続 | PostgreSQL接続、Dockerコンテナ状態 |
| 5 | マイグレーション | マイグレーションファイル存在、適用状態 |
| 6 | シードデータ | seed.ts存在、prisma.seed設定 |
| 7 | 環境変数 | .envファイル存在、必須変数設定 |
| 8 | API 疎通 | 主要エンドポイントへのリクエスト |

## 判定結果

| マーク | 意味 |
|--------|------|
| ✅ PASS | チェック成功 |
| ⚠️ WARN | 警告（動作に影響する可能性あり） |
| ❌ FAIL | 失敗（統合テスト実行前に解決必要） |
| ⏭️ SKIP | スキップ（該当なし） |

## 対応プロジェクト構成

- **フロントエンド**: React/Vue/Angular（Vite/Webpack）
- **バックエンド**: NestJS/Express
- **ORM**: Prisma
- **DB**: PostgreSQL
- **コンテナ**: Docker Compose

## 環境変数

チェック対象の環境変数:

```bash
DATABASE_HOST      # データベースホスト
DATABASE_PORT      # データベースポート
DATABASE_USER      # データベースユーザー
DATABASE_PASSWORD  # データベースパスワード
DATABASE_NAME      # データベース名
```

## カスタマイズ

### バックエンドポート変更

```bash
BACKEND_PORT=4000 ~/multi-agent-shogun/bin/pre-integration-test-check.sh /path/to/project
```

### ヘルスエンドポイント変更

```bash
HEALTH_ENDPOINT=/api/health ~/multi-agent-shogun/bin/pre-integration-test-check.sh /path/to/project
```

## 出力例

```
╔════════════════════════════════════════════════════════════════╗
║  統合テスト前チェックリスト                                    ║
╚════════════════════════════════════════════════════════════════╝

対象プロジェクト: ~/projects/s-automation
実行日時: 2026-03-02 15:16:01

────────────────────────────────────────────────────────────────
  プロジェクト構成検出
────────────────────────────────────────────────────────────────
  ✅ PASS: フロントエンドディレクトリ検出: frontend/
  ✅ PASS: バックエンドディレクトリ検出: backend/
  ✅ PASS: Prisma検出: prisma/schema.prisma

... (各チェック結果) ...

════════════════════════════════════════════════════════════════
  チェック結果サマリ
════════════════════════════════════════════════════════════════

  ✅ PASS: 10 件
  ⚠️ WARN: 3 件
  ❌ FAIL: 0 件

╔════════════════════════════════════════════════════════════════╗
║  🎉 統合テスト実行準備完了！                                   ║
╚════════════════════════════════════════════════════════════════╝
```

## 終了コード

| コード | 意味 |
|--------|------|
| 0 | チェック成功（FAILなし） |
| 1 | チェック失敗（FAILあり） |

## 関連スキル

このスクリプトは以下のスキルの観点を参考にしている:

- `cicd-health-checker`: CI/CD設定チェック
- `fe-be-consistency-checker`: FE/BE整合性チェック
- `repo-test-status-checker`: テスト整備状況チェック

## 作成経緯

- **cmd_155**: 足軽7号が session_002（足軽雑談会）で提案
- 殿より「提案者の足軽7に任せよ」との指示を受け実装

## 更新履歴

| 日付 | バージョン | 内容 |
|------|------------|------|
| 2026-03-02 | v1.0.0 | 初版作成（足軽7号） |
