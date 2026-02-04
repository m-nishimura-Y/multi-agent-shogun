# CI/CD問題・提案 ISSUE テンプレート

## 使用方法
このテンプレートをコピーし、`{{変数}}` を実際の値に置き換えてISSUEを作成せよ。

---

## プラットフォーム別設定ファイル

| プラットフォーム | 設定ファイル | 備考 |
|-----------------|-------------|------|
| GitHub Actions | `.github/workflows/*.yml` | 複数ワークフロー可 |
| GitLab CI | `.gitlab-ci.yml` | ルート配置必須 |
| CircleCI | `.circleci/config.yml` | v2.1推奨 |
| Jenkins | `Jenkinsfile` | Declarative Pipeline推奨 |
| Azure Pipelines | `azure-pipelines.yml` | - |

---

## ISSUE タイトル
```
[CI/CD] {{リポジトリ名}}: {{問題/提案の要約}}
```

## 推奨ラベル
```
ci-cd, automation, devops, infrastructure, {{追加ラベル}}
```

## ISSUE 本文

```markdown
## 概要
{{問題または提案の簡潔な説明}}

## 現状
- **プラットフォーム**: {{GitHub Actions / GitLab CI / CircleCI / Jenkins / なし}}
- **設定ファイル**: {{ファイルパス or 未設定}}
- **現在のワークフロー**: {{概要 or なし}}

## 検出された問題

| # | 深刻度 | 問題 | ファイル | 詳細 |
|---|--------|------|----------|------|
| 1 | {{HIGH/MEDIUM/LOW}} | {{問題内容}} | {{ファイルパス}} | {{詳細説明}} |

## 提案

### 推奨ワークフロー構成

以下のステージを段階的に導入することを推奨：

| ステージ | 内容 | 優先度 | 推奨ツール |
|----------|------|--------|-----------|
| Lint/Format | コードスタイルチェック | 🔴 高 | ESLint, Prettier, PHP-CS-Fixer |
| Unit Test | ユニットテスト実行 | 🔴 高 | Jest, PHPUnit, pytest |
| Security Scan | 脆弱性スキャン | 🟠 中 | npm audit, Trivy, Snyk |
| Build | ビルド・コンパイル | 🔴 高 | webpack, vite, docker build |
| Deploy (STG) | ステージング環境 | 🟡 任意 | {{デプロイ先}} |
| Deploy (PROD) | 本番環境 | 🟡 任意 | {{デプロイ先}} |

### 推奨構成サンプル

```yaml
# 例: GitHub Actions
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Lint
        run: {{lintコマンド}}

  test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - name: Test
        run: {{testコマンド}}

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Security Scan
        run: {{securityコマンド}}

  build:
    runs-on: ubuntu-latest
    needs: [lint, test]
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: {{buildコマンド}}
```

### 対応項目
- [ ] CI/CD設定ファイルの作成
- [ ] Lint/Formatの設定
- [ ] テスト自動実行の設定
- [ ] セキュリティスキャンの導入
- [ ] ビルドワークフローの設定
- [ ] デプロイ自動化（任意）

## 期待される効果

### 定性的効果
- {{効果1: 例）コード品質の向上}}
- {{効果2: 例）デプロイミスの削減}}

### 定量的効果（コスト/ROI）

| 項目 | 現状 | 導入後（予測） | 削減効果 |
|------|------|---------------|---------|
| 手動テスト工数 | {{X時間/週}} | {{Y時間/週}} | {{削減率}}% |
| デプロイ頻度 | {{月X回}} | {{月Y回}} | {{X倍向上}} |
| バグ検出タイミング | {{本番後}} | {{PR時}} | 早期検出 |
| リリースリードタイム | {{X日}} | {{Y日}} | {{削減率}}% |

**ROI試算**: CI/CD構築工数 {{X時間}} に対し、年間 {{Y時間}} の工数削減が見込まれる。

## 参考情報
- 検出ツール: {{使用したスキルや手法}}
- 検出日: {{YYYY-MM-DD}}
- 検出者: multi-agent-shogun

---
このISSUEは [multi-agent-shogun](https://github.com/m-nishimura-Y/multi-agent-shogun) によって作成されました。
```
