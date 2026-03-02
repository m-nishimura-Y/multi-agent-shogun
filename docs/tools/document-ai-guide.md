# document-ai（請求書OCR API）活用ガイド

> **Version**: 1.0.0
> **Last Updated**: 2026-03-02

## 概要

document-aiは、Google Cloud Document AIを活用した請求書自動抽出APIである。
PDFファイルから請求書データ（金額、支払方法、取引先名等）を自動抽出する。

### 主な機能

- **OCRによる自動テキスト抽出**: Document AI Form Parserによる高精度OCR
- **構造化データ抽出**: 請求金額（税込/税抜）、消費税、会社名、T番号などを自動抽出
- **支払方法の自動判定**: 口座振替/振込をスコアリング方式で自動識別
- **多様な請求書形式に対応**: KDDI、ソフトバンク、大塚商会、エアネット等

### リポジトリ

https://github.com/Yuidea-DxG/document-ai

---

## API仕様

### エンドポイント

```
POST /api/v1/ocr/extract
```

### 認証

Bearer Token認証。環境変数 `OCR_API_KEY` で設定されたAPIキーを使用。

```
Authorization: Bearer {OCR_API_KEY}
```

### リクエスト

```json
{
  "drive_url": "https://drive.google.com/file/d/{FILE_ID}/view",
  "user_email": "user@yuidea.co.jp"
}
```

| フィールド | 型 | 必須 | 説明 |
|-----------|------|------|------|
| drive_url | string | ○ | Google DriveのファイルURL |
| user_email | string | ○ | 委任対象のユーザーメールアドレス（@yuidea.co.jp） |

### レスポンス（成功時）

```json
{
  "success": true,
  "data": {
    "invoice_issue_date": "2025/01/15",
    "pay_method": "口座振替",
    "pay_amt_excl_tax": 10000,
    "pay_amt_incl_tax": 11000,
    "pay_tax_amt": 1000,
    "inv_receipt_method": "郵送",
    "supplier_name": "株式会社XXX",
    "qualified_invoice_number": "T1234567890123"
  },
  "extraction_details": {
    "invoice_issue_date_source": "請求日: 2025/01/15",
    "pay_method_source": "口座振替",
    "pay_method_confidence": 0.95,
    "pay_amt_incl_tax_source": "ご請求額: ¥11,000",
    "pay_amt_excl_tax_source": "税抜金額: ¥10,000",
    "pay_tax_amt_source": "消費税: ¥1,000"
  }
}
```

### 抽出フィールド

| フィールド | 型 | 説明 |
|-----------|------|------|
| invoice_issue_date | string | 請求書発行日（YYYY/MM/DD形式） |
| pay_method | string | 支払方法（口座振替/振込(30日後振込)等） |
| pay_amt_excl_tax | int | 税抜金額 |
| pay_amt_incl_tax | int | 税込金額 |
| pay_tax_amt | int | 消費税額 |
| inv_receipt_method | string | 受領方法（郵送/メール/WebサイトDL） |
| supplier_name | string | 請求元会社名 |
| qualified_invoice_number | string | 適格請求書番号（T番号） |

### レスポンス（エラー時）

```json
{
  "success": false,
  "error": {
    "code": "PDF_DOWNLOAD_FAILED",
    "message": "PDFのダウンロードに失敗しました"
  }
}
```

### エラーコード一覧

| コード | 説明 |
|--------|------|
| INVALID_DRIVE_URL | Drive URLの形式が不正 |
| INVALID_USER_EMAIL | ユーザーメールアドレスが不正（@yuidea.co.jp以外） |
| DELEGATION_ERROR | ドメイン委任エラー |
| FILE_NOT_FOUND | ファイルが見つからない |
| PDF_DOWNLOAD_FAILED | PDFダウンロード失敗 |
| PDF_TOO_LARGE | ファイルサイズ超過（40MB制限） |
| PDF_TOO_MANY_PAGES | ページ数超過（30ページ制限） |
| OCR_PROCESSING_FAILED | Document AI処理失敗 |
| EXTRACTION_FAILED | データ抽出失敗 |
| CONFIGURATION_ERROR | 環境設定エラー |

---

## 使用例

### curl

```bash
curl -X POST "https://invoice-ocr-api-xxxx.run.app/api/v1/ocr/extract" \
  -H "Authorization: Bearer ${OCR_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "drive_url": "https://drive.google.com/file/d/1ABC123xyz/view",
    "user_email": "user@yuidea.co.jp"
  }'
```

### TypeScript（NestJS）

```typescript
import { Injectable, HttpException, HttpStatus } from '@nestjs/common';

interface OcrExtractResponse {
  success: boolean;
  data?: {
    invoice_issue_date: string | null;
    pay_method: string | null;
    pay_amt_excl_tax: number | null;
    pay_amt_incl_tax: number | null;
    pay_tax_amt: number | null;
    supplier_name: string | null;
    qualified_invoice_number: string | null;
  };
  error?: {
    code: string;
    message: string;
  };
}

@Injectable()
export class OcrService {
  private readonly apiUrl = process.env.OCR_API_URL;
  private readonly apiKey = process.env.OCR_API_KEY;

  async extractInvoiceData(driveUrl: string, userEmail: string): Promise<OcrExtractResponse> {
    const response = await fetch(`${this.apiUrl}/api/v1/ocr/extract`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        drive_url: driveUrl,
        user_email: userEmail,
      }),
    });

    if (!response.ok) {
      throw new HttpException('OCR API error', HttpStatus.BAD_GATEWAY);
    }

    return response.json();
  }
}
```

### Python

```python
import requests

def extract_invoice_data(drive_url: str, user_email: str) -> dict:
    """請求書PDFからデータを抽出"""
    api_url = os.getenv("OCR_API_URL")
    api_key = os.getenv("OCR_API_KEY")

    response = requests.post(
        f"{api_url}/api/v1/ocr/extract",
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        json={
            "drive_url": drive_url,
            "user_email": user_email,
        },
    )

    response.raise_for_status()
    return response.json()
```

---

## S-automationでの活用シナリオ

### シナリオ1: 請求書PDF→伝票自動作成

1. ユーザーがGoogle Driveに請求書PDFをアップロード
2. S-automationがdocument-ai APIを呼び出し
3. 抽出データから支払伝票を自動生成
   - `invoice_issue_date` → 請求日
   - `pay_amt_incl_tax` → 支払金額
   - `pay_method` → 支払方法（口座振替/振込）
   - `supplier_name` → 取引先名
4. ユーザーは確認・修正のみで伝票登録完了

### シナリオ2: 既存伝票へのOCRデータ補完

1. 手入力済みの伝票に請求書PDFを添付
2. 「OCR読取」ボタンでAPIを呼び出し
3. 抽出データで空欄フィールドを自動補完
4. 手入力との差異があれば確認ダイアログを表示

### シナリオ3: 一括処理

1. 複数の請求書PDFを選択
2. バッチでAPIを呼び出し
3. 抽出結果を一覧表示
4. 確認後、一括で伝票作成

---

## 注意事項

### 制限事項

- **ファイルサイズ**: 40MB以下
- **ページ数**: 30ページ以下
- **対応形式**: PDFのみ
- **ドメイン制限**: @yuidea.co.jp のユーザーのみ

### 精度について

- **金額抽出**: 高精度（複数パターンで抽出、検証あり）
- **支払方法判定**: スコアリング方式（信頼度が低い場合は手動確認を推奨）
- **日付抽出**: 複数の日付形式に対応（YYYY/MM/DD, YYYY年MM月DD日 等）

### 環境変数

| 変数名 | 説明 |
|--------|------|
| OCR_API_URL | OCR APIのベースURL |
| OCR_API_KEY | API認証キー |

---

## 関連リソース

- [リポジトリ](https://github.com/Yuidea-DxG/document-ai)
- [Cloud Runデプロイガイド](https://github.com/Yuidea-DxG/document-ai/blob/main/docs/deployment_guide.md)
