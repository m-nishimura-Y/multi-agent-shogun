# ディレクトリ構成ルール

> **Version**: 1.0.0
> **Last Updated**: 2026-02-06
> **対象**: arms-mock プロジェクト

## 概要

本ドキュメントは、arms-mock プロジェクトにおけるディレクトリ構成の標準ルールを定義する。
全エージェントはこのルールに従ってファイルを配置すること。

---

## バックエンド構成（NestJS）

```
backend/src/
├── main.ts                    # エントリーポイント
├── app.module.ts              # ルートモジュール
├── app.controller.ts          # ルートコントローラー
├── app.service.ts             # ルートサービス
│
├── auth/                      # 認証モジュール
│   ├── auth.module.ts
│   ├── auth.controller.ts
│   ├── auth.service.ts
│   ├── jwt.strategy.ts
│   ├── jwt-auth.guard.ts
│   ├── index.ts
│   ├── dto/
│   │   └── login.dto.ts
│   ├── entities/
│   │   └── user.entity.ts     # ★ 認証関連Entityはここ
│   ├── decorators/
│   │   ├── public.decorator.ts
│   │   └── roles.decorator.ts
│   └── guards/
│       └── roles.guard.ts
│
├── database/                  # データベース設定
│   ├── data-source.ts
│   └── seeds/                 # シードデータ
│       ├── index.ts
│       ├── user.seed.ts
│       └── ...
│
├── entities/                  # ★ 共通Entity（非推奨：モジュール配下推奨）
│   └── ...
│
├── {module}/                  # 各ビジネスモジュール
│   ├── {module}.module.ts     # モジュール定義
│   ├── {module}.controller.ts # コントローラー
│   ├── {module}.service.ts    # サービス
│   ├── dto/
│   │   ├── create-{module}.dto.ts
│   │   ├── update-{module}.dto.ts
│   │   └── search-{module}.dto.ts
│   └── entities/
│       └── {module}.entity.ts # ★ Entityはモジュール配下に配置
│
└── 現在のモジュール一覧:
    ├── product/       # 商品マスタ
    ├── catalog/       # カタログ
    ├── media/         # 媒体
    ├── promotion/     # 販促
    ├── promotion-text/# 販促文
    ├── mark/          # マーク
    ├── block-entry/   # ブロックエントリ
    ├── composition-export/  # 構成表出力
    ├── manuscript-export/   # 原稿出力
    ├── category/      # カテゴリ
    ├── vendor/        # ベンダー
    └── job/           # バッチジョブ
```

### バックエンド配置ルール

| 種別 | 配置場所 | 例 |
|------|----------|-----|
| Entity | `{module}/entities/` | `product/entities/product.entity.ts` |
| DTO | `{module}/dto/` | `product/dto/create-product.dto.ts` |
| Controller | `{module}/` | `product/product.controller.ts` |
| Service | `{module}/` | `product/product.service.ts` |
| Module | `{module}/` | `product/product.module.ts` |
| Guard | `auth/guards/` | `auth/guards/roles.guard.ts` |
| Decorator | `auth/decorators/` | `auth/decorators/public.decorator.ts` |
| Seed | `database/seeds/` | `database/seeds/product.seed.ts` |

---

## フロントエンド構成（React + TypeScript）

```
frontend/src/
├── main.tsx                   # エントリーポイント
├── App.tsx                    # ルートコンポーネント
├── App.css
├── index.css
│
├── assets/                    # 静的アセット
│   └── ...
│
├── components/                # 共通コンポーネント
│   ├── {Component}.tsx
│   ├── promotion/             # ドメイン別コンポーネント
│   │   ├── ImageSettingTab.tsx
│   │   ├── ColumnTab.tsx
│   │   ├── PromotionInfoTab.tsx
│   │   ├── MaterialTab.tsx
│   │   ├── PublicationHistoryTab.tsx
│   │   ├── MarkTab.tsx
│   │   ├── ECDetailTab.tsx
│   │   ├── GiftTab.tsx
│   │   └── index.ts
│   └── ...
│
├── pages/                     # ページコンポーネント
│   ├── LoginPage.tsx
│   ├── DashboardPage.tsx
│   ├── ProductListPage.tsx
│   ├── ProductDetailPage.tsx
│   ├── PromotionMasterPage.tsx
│   ├── MediaBlockListPage.tsx
│   ├── MarkManagementPage.tsx
│   ├── ImageManagementPage.tsx
│   └── ...
│
├── services/                  # APIサービス
│   ├── apiClient.ts           # 共通APIクライアント
│   ├── authService.ts
│   ├── productService.ts
│   ├── promotionService.ts
│   ├── mediaService.ts
│   ├── blockService.ts
│   └── ...
│
├── stores/                    # 状態管理（Zustand）
│   └── authStore.ts
│
└── types/                     # 型定義
    ├── auth.ts
    ├── product.ts
    ├── promotion.ts
    ├── media.ts
    └── ...
```

### フロントエンド配置ルール

| 種別 | 配置場所 | 命名規則 |
|------|----------|----------|
| ページ | `pages/` | `{Name}Page.tsx` |
| 共通コンポーネント | `components/` | `{Name}.tsx` |
| ドメイン別コンポーネント | `components/{domain}/` | `{Name}Tab.tsx` 等 |
| APIサービス | `services/` | `{domain}Service.ts` |
| 型定義 | `types/` | `{domain}.ts` |
| ストア | `stores/` | `{domain}Store.ts` |
| カスタムフック | `hooks/` | `use{Name}.ts` |

---

## 禁止事項

### 絶対に避けるべき配置

```
❌ 禁止パターン
```

| 禁止事項 | 理由 | 正しい配置 |
|----------|------|------------|
| `src/` 直下に Entity | モジュール管理が困難 | `{module}/entities/` |
| 同名 Entity の重複配置 | ビルドエラー・型混乱 | 1箇所のみに配置 |
| `services/` に Entity | 責務の混在 | `{module}/entities/` |
| `pages/` に API 呼び出し直接記述 | 保守性低下 | `services/` 経由 |
| `components/` にページ | 責務の混在 | `pages/` |

### 過去のバグ事例

#### BUG-XXX: 重複Entity問題

```
❌ 問題のあった構成:
backend/src/
├── entities/
│   └── user.entity.ts    # ← ここにも
└── auth/
    └── entities/
        └── user.entity.ts  # ← ここにも（重複！）

✅ 正しい構成:
backend/src/
└── auth/
    └── entities/
        └── user.entity.ts  # ← ここだけ
```

**影響**: TypeORMのEntity重複登録エラー、型定義の混乱

---

## モジュール新規作成時のチェックリスト

### バックエンド

```bash
# 新規モジュール作成時
mkdir -p backend/src/{module}/dto
mkdir -p backend/src/{module}/entities

# 必要ファイル
touch backend/src/{module}/{module}.module.ts
touch backend/src/{module}/{module}.controller.ts
touch backend/src/{module}/{module}.service.ts
touch backend/src/{module}/dto/{module}.dto.ts
touch backend/src/{module}/entities/{module}.entity.ts
```

- [ ] `{module}.module.ts` 作成
- [ ] `{module}.controller.ts` 作成
- [ ] `{module}.service.ts` 作成
- [ ] `dto/` ディレクトリ作成
- [ ] `entities/` ディレクトリ作成
- [ ] `app.module.ts` に import 追加

### フロントエンド

- [ ] `pages/{Name}Page.tsx` 作成
- [ ] `services/{domain}Service.ts` 作成
- [ ] `types/{domain}.ts` 作成
- [ ] `App.tsx` にルーティング追加

---

## 命名規則

### ファイル名

| 種別 | 規則 | 例 |
|------|------|-----|
| Entity (BE) | `{name}.entity.ts` | `product.entity.ts` |
| DTO (BE) | `{action}-{name}.dto.ts` | `create-product.dto.ts` |
| Controller (BE) | `{name}.controller.ts` | `product.controller.ts` |
| Service (BE) | `{name}.service.ts` | `product.service.ts` |
| Module (BE) | `{name}.module.ts` | `product.module.ts` |
| Page (FE) | `{Name}Page.tsx` | `ProductListPage.tsx` |
| Component (FE) | `{Name}.tsx` | `ProductForm.tsx` |
| Service (FE) | `{name}Service.ts` | `productService.ts` |
| Type (FE) | `{name}.ts` | `product.ts` |
| Store (FE) | `{name}Store.ts` | `authStore.ts` |
| Hook (FE) | `use{Name}.ts` | `useProducts.ts` |

### 変数名・クラス名

| 種別 | 規則 | 例 |
|------|------|-----|
| Entity クラス | PascalCase | `Product` |
| DTO クラス | PascalCase + Dto | `CreateProductDto` |
| Controller クラス | PascalCase + Controller | `ProductController` |
| Service クラス | PascalCase + Service | `ProductService` |
| React コンポーネント | PascalCase | `ProductList` |
| 関数 | camelCase | `getProducts` |
| 定数 | UPPER_SNAKE_CASE | `API_BASE_URL` |

---

## 関連ドキュメント

- [APIスキーマ](../../output/detailed_design/api_schema.md)
- [テーブル構造](../../output/basic_design/table_structure.md)
- [コーディング規約](./coding-standards.md)
