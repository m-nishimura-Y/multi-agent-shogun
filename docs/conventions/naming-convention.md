# 命名規則ガイド

> 作成日: 2026-02-06
> 対象: ARMS プロジェクト
> 目的: FE-BE間のフィールド名統一と新規参画者のオンボーディング

---

## 概要

本プロジェクトでは、レイヤーごとに異なる命名規則を採用し、自動変換によって一貫性を保っている。

| レイヤー | 命名規則 | 例 |
|---------|---------|-----|
| API（JSON） | キャメルケース | `janCd`, `startDate` |
| DB（PostgreSQL） | スネークケース | `jan_cd`, `start_date` |
| フロントエンド（TypeScript） | キャメルケース | `janCd`, `startDate` |
| ファイル名 | ケバブケース | `product-list-page.tsx` |
| コンポーネント名 | パスカルケース | `ProductListPage` |

---

## 1. APIフィールド名（キャメルケース）

### ルール
- すべてのAPIリクエスト/レスポンスのフィールド名は **キャメルケース** を使用
- 先頭は小文字、単語の区切りは大文字

### 例

```json
{
  "janCd": "12345678",
  "startDate": "2026-01-01",
  "endDate": "2026-12-31",
  "productTypeFlg": 1,
  "promotionText": "お買い得！",
  "makerName": "株式会社サンプル",
  "haisoFukaArea1": 0
}
```

### 具体的な変換例

| スネークケース（DB） | キャメルケース（API） |
|---------------------|---------------------|
| `jan_cd` | `janCd` |
| `start_date` | `startDate` |
| `end_date` | `endDate` |
| `product_type_flg` | `productTypeFlg` |
| `section1_cd` | `section1Cd` |
| `maker_name_kana` | `makerNameKana` |
| `haiso_fuka_area_1` | `haisoFukaArea1` |
| `promotion_text` | `promotionText` |

---

## 2. DBカラム名（スネークケース）

### ルール
- PostgreSQL標準に従い **スネークケース** を使用
- すべて小文字、単語の区切りはアンダースコア

### 例

```sql
CREATE TABLE products (
  jan_cd VARCHAR(8) PRIMARY KEY,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  product_type_flg NUMERIC(1),
  maker_name VARCHAR(128),
  promotion_text VARCHAR(512)
);
```

---

## 3. フロントエンド型定義（キャメルケース）

### ルール
- TypeScriptの型定義は **APIに合わせてキャメルケース** を使用
- インターフェース名は **パスカルケース**

### 例

```typescript
// types/product.ts
export interface Product {
  janCd: string;
  startDate: string;
  endDate: string;
  productTypeFlg: number;
  makerName: string;
  promotionText: string;
}

export interface ProductListResponse {
  products: Product[];
  totalCount: number;
  currentPage: number;
  totalPages: number;
}
```

---

## 4. ファイル名（ケバブケース）

### ルール
- React/TypeScriptファイルは **ケバブケース** を使用
- すべて小文字、単語の区切りはハイフン
- 拡張子: `.tsx`（コンポーネント）、`.ts`（ユーティリティ）

### 例

```
src/
├── pages/
│   ├── product-list-page.tsx
│   ├── product-detail-page.tsx
│   └── promotion-master-page.tsx
├── components/
│   ├── product-table.tsx
│   └── search-form.tsx
├── services/
│   ├── api-client.ts
│   └── product-service.ts
└── types/
    ├── product.ts
    └── promotion.ts
```

---

## 5. コンポーネント名（パスカルケース）

### ルール
- Reactコンポーネント名は **パスカルケース** を使用
- 先頭大文字、単語の区切りも大文字

### 例

```typescript
// product-list-page.tsx
export const ProductListPage = () => {
  return <div>...</div>;
};

// product-table.tsx
export const ProductTable = ({ products }: Props) => {
  return <table>...</table>;
};
```

---

## 6. 自動変換の仕組み

### 概要

バックエンド（スネークケース）とフロントエンド（キャメルケース）の変換は、
`apiClient.ts` のAxiosインターセプターで **自動的に** 行われる。

### 実装箇所

```
frontend/src/services/apiClient.ts
```

### 変換フロー

```
[フロントエンド]          [API通信]              [バックエンド]

  janCd          ──────────────────────────→   jan_cd
  startDate                                    start_date

  janCd          ←──────────────────────────   jan_cd
  startDate        (自動変換)                  start_date
```

### 実装コード（抜粋）

```typescript
// apiClient.ts

// スネークケース → キャメルケース変換関数
const toCamelCase = (str: string): string => {
  return str.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
};

// レスポンスインターセプターで自動変換
client.interceptors.response.use(
  (response) => {
    if (response.data) {
      response.data = convertKeysToCamelCase(response.data);
    }
    return response;
  }
);
```

### 開発者への影響

- **フロントエンド開発者**: 常にキャメルケースで実装すればOK
- **バックエンド開発者**: 常にスネークケースで実装すればOK
- **変換は自動**: 手動での変換は不要

---

## 7. よくある質問（FAQ）

### Q1: 新しいフィールドを追加する場合は？

A: レイヤーごとの規則に従う。
- DB: `new_field_name`（スネークケース）
- API/FE: `newFieldName`（キャメルケース）
- 自動変換されるため、明示的な変換コードは不要

### Q2: 数字を含むフィールド名は？

A: 数字はそのまま保持。
- DB: `section1_cd`, `haiso_fuka_area_1`
- API/FE: `section1Cd`, `haisoFukaArea1`

### Q3: 略語（CD, ID等）は？

A: 略語も同様のルールに従う。
- DB: `jan_cd`, `user_id`
- API/FE: `janCd`, `userId`

### Q4: フロント側で型エラーが出る場合は？

A: 型定義がキャメルケースになっているか確認。
スネークケースの型定義が残っていると、自動変換後にミスマッチが発生する。

---

## 8. 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| `skills/api-response-case-converter.md` | 変換スキルの詳細実装 |
| `frontend/src/services/apiClient.ts` | 実際の変換実装 |
| `output/detailed_design/api_schema.md` | APIスキーマ定義 |

---

## 9. 変更履歴

| 日付 | 変更内容 | 担当 |
|------|---------|------|
| 2026-02-06 | 初版作成 | 足軽5号（cmd_028） |

---

**以上**
