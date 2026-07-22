# GdriveService 設計書

> **作成者**: ashigaru6
> **作成日**: 2026-03-03
> **関連cmd**: cmd_177 (Gドライブ連携実装)
> **ステータス**: Draft

---

## 3. GdriveService設計

### 3.1 サービス概要

GdriveServiceは、Google Drive API v3を使用してGドライブ上のファイル操作を行うサービスである。
支払伝票処理自動化において、以下の役割を担う：

1. **ファイル一覧取得**: 未処理フォルダ内のファイル一覧を取得
2. **ファイル移動**: 処理完了ファイルを「処理済み」フォルダへ移動
3. **フォルダ自動生成**: 年度/月ごとのフォルダ構成を自動作成

**設計方針**:
- getFileContent()は実装しない（OCR APIがドメイン委任で直接取得）
- Service Account認証を使用（GCP IAP連携済み環境）
- 共有ドライブ対応（supportsAllDrives: true）

---

### 3.2 メソッド一覧

| メソッド | 用途 | 戻り値 |
|----------|------|--------|
| `listFiles(targetMonth)` | 指定月の未処理ファイル一覧取得 | `DriveFile[]` |
| `moveToProcessed(fileId, targetMonth)` | ファイルを処理済みフォルダへ移動 | `boolean` |
| `ensureFolderStructure(targetMonth)` | 年度/月フォルダの自動生成 | `FolderIds` |

---

#### 3.2.1 listFiles()

**目的**: 指定月の「未処理」フォルダ内のファイル一覧を取得する。

**シグネチャ**:
```typescript
async listFiles(targetMonth: TargetMonth): Promise<DriveFile[]>
```

**パラメータ**:
```typescript
interface TargetMonth {
  fiscalYear: string;  // 年度（例: "2025年度"）
  month: string;       // 月（例: "4"）
}
```

**戻り値**:
```typescript
interface DriveFile {
  id: string;              // Google Drive ファイルID
  name: string;            // ファイル名
  mimeType: string;        // MIMEタイプ
  createdTime: string;     // 作成日時（ISO 8601）
  modifiedTime: string;    // 更新日時（ISO 8601）
  size?: string;           // ファイルサイズ（バイト）
  webViewLink?: string;    // プレビューリンク
}
```

**実装ロジック**:
```typescript
async listFiles(targetMonth: TargetMonth): Promise<DriveFile[]> {
  // 1. フォルダパス解決
  const unprocessedFolderId = await this.resolveFolderId(
    targetMonth,
    'unprocessed'
  );

  // 2. files.list API呼び出し
  const response = await this.drive.files.list({
    q: `'${unprocessedFolderId}' in parents and trashed = false`,
    fields: 'files(id, name, mimeType, createdTime, modifiedTime, size, webViewLink)',
    supportsAllDrives: true,
    includeItemsFromAllDrives: true,
    orderBy: 'createdTime desc',
    pageSize: 100,
  });

  return response.data.files || [];
}
```

**エラーハンドリング**:
| エラー | 対応 |
|--------|------|
| フォルダが存在しない | `ensureFolderStructure()` で自動生成 |
| 認証エラー | `GoogleDriveAuthError` をスロー |
| API制限超過 | 指数バックオフでリトライ（最大3回） |

---

#### 3.2.2 moveToProcessed()

**目的**: 処理完了したファイルを「処理済み」フォルダへ移動する。

**シグネチャ**:
```typescript
async moveToProcessed(
  fileId: string,
  targetMonth: TargetMonth
): Promise<boolean>
```

**パラメータ**:
| パラメータ | 型 | 説明 |
|-----------|------|------|
| fileId | string | 移動対象ファイルのGoogle Drive ID |
| targetMonth | TargetMonth | 対象年度・月（移動先フォルダ特定用） |

**実装ロジック**:
```typescript
async moveToProcessed(
  fileId: string,
  targetMonth: TargetMonth
): Promise<boolean> {
  // 1. フォルダID解決
  const unprocessedFolderId = await this.resolveFolderId(
    targetMonth,
    'unprocessed'
  );
  const processedFolderId = await this.resolveFolderId(
    targetMonth,
    'processed'
  );

  // 2. files.update API呼び出し（親フォルダ変更）
  await this.drive.files.update({
    fileId,
    addParents: processedFolderId,
    removeParents: unprocessedFolderId,
    supportsAllDrives: true,
    fields: 'id, parents',
  });

  this.logger.log(`File ${fileId} moved to processed folder`);
  return true;
}
```

**エラーハンドリング**:
| エラー | 対応 |
|--------|------|
| ファイルが存在しない | `FileNotFoundError` をスロー |
| 権限不足 | `PermissionDeniedError` をスロー |
| 処理済みフォルダが存在しない | `ensureFolderStructure()` で自動生成後リトライ |

---

#### 3.2.3 ensureFolderStructure()

**目的**: 年度/月ごとのフォルダ構成を自動生成する。

**シグネチャ**:
```typescript
async ensureFolderStructure(targetMonth: TargetMonth): Promise<FolderIds>
```

**戻り値**:
```typescript
interface FolderIds {
  yearFolderId: string;       // 年度フォルダID
  monthFolderId: string;      // 月フォルダID
  unprocessedFolderId: string; // 未処理フォルダID
  processedFolderId: string;   // 処理済みフォルダID
}
```

**実装ロジック**:
```typescript
async ensureFolderStructure(targetMonth: TargetMonth): Promise<FolderIds> {
  const rootFolderId = this.configService.get('GDRIVE_ROOT_FOLDER_ID');

  // 1. 年度フォルダ確認・作成
  const yearFolderName = targetMonth.fiscalYear;
  let yearFolderId = await this.findFolderByName(rootFolderId, yearFolderName);
  if (!yearFolderId) {
    yearFolderId = await this.createFolder(rootFolderId, yearFolderName);
    this.logger.log(`Created year folder: ${yearFolderName}`);
  }

  // 2. 月フォルダ確認・作成
  const monthFolderName = `${targetMonth.month}月締め`;
  let monthFolderId = await this.findFolderByName(yearFolderId, monthFolderName);
  if (!monthFolderId) {
    monthFolderId = await this.createFolder(yearFolderId, monthFolderName);
    this.logger.log(`Created month folder: ${monthFolderName}`);
  }

  // 3. 未処理フォルダ確認・作成
  let unprocessedFolderId = await this.findFolderByName(monthFolderId, '未処理');
  if (!unprocessedFolderId) {
    unprocessedFolderId = await this.createFolder(monthFolderId, '未処理');
    this.logger.log(`Created unprocessed folder`);
  }

  // 4. 処理済みフォルダ確認・作成
  let processedFolderId = await this.findFolderByName(monthFolderId, '処理済み');
  if (!processedFolderId) {
    processedFolderId = await this.createFolder(monthFolderId, '処理済み');
    this.logger.log(`Created processed folder`);
  }

  return {
    yearFolderId,
    monthFolderId,
    unprocessedFolderId,
    processedFolderId,
  };
}
```

**ヘルパーメソッド**:
```typescript
// フォルダ名でフォルダIDを検索
private async findFolderByName(
  parentId: string,
  folderName: string
): Promise<string | null> {
  const response = await this.drive.files.list({
    q: `'${parentId}' in parents and name = '${folderName}' and mimeType = 'application/vnd.google-apps.folder' and trashed = false`,
    fields: 'files(id)',
    supportsAllDrives: true,
    includeItemsFromAllDrives: true,
  });
  return response.data.files?.[0]?.id || null;
}

// フォルダ作成
private async createFolder(
  parentId: string,
  folderName: string
): Promise<string> {
  const response = await this.drive.files.create({
    requestBody: {
      name: folderName,
      mimeType: 'application/vnd.google-apps.folder',
      parents: [parentId],
    },
    supportsAllDrives: true,
    fields: 'id',
  });
  return response.data.id!;
}
```

---

### 3.3 Google Service Account認証

#### 3.3.1 認証方式

**Service Account + ドメイン全体の委任**を使用する。

| 項目 | 値 |
|------|-----|
| 認証方式 | Service Account (JWT) |
| スコープ | `https://www.googleapis.com/auth/drive` |
| ドメイン委任 | 有効（共有ドライブアクセス用） |
| 認証情報格納 | GCP Secret Manager |

#### 3.3.2 認証フロー

```
┌─────────────────┐
│   NestJS App    │
└────────┬────────┘
         │ 1. Secret Manager から認証情報取得
         ▼
┌─────────────────┐
│ Secret Manager  │
│ (sa-key.json)   │
└────────┬────────┘
         │ 2. JWT生成・署名
         ▼
┌─────────────────┐
│  Google OAuth   │
│   Token API     │
└────────┬────────┘
         │ 3. Access Token 発行
         ▼
┌─────────────────┐
│ Google Drive    │
│     API v3      │
└─────────────────┘
```

#### 3.3.3 実装パターン

```typescript
// gdrive.module.ts
import { Module } from '@nestjs/common';
import { GdriveService } from './gdrive.service';

@Module({
  providers: [GdriveService],
  exports: [GdriveService],
})
export class GdriveModule {}
```

```typescript
// gdrive.service.ts
import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { google, drive_v3 } from 'googleapis';

@Injectable()
export class GdriveService implements OnModuleInit {
  private readonly logger = new Logger(GdriveService.name);
  private drive: drive_v3.Drive;

  constructor(private readonly configService: ConfigService) {}

  async onModuleInit() {
    await this.initializeClient();
  }

  private async initializeClient(): Promise<void> {
    // 環境変数から認証情報を取得
    const credentials = JSON.parse(
      this.configService.get<string>('GOOGLE_SERVICE_ACCOUNT_KEY') || '{}'
    );

    const auth = new google.auth.GoogleAuth({
      credentials,
      scopes: ['https://www.googleapis.com/auth/drive'],
    });

    this.drive = google.drive({ version: 'v3', auth });
    this.logger.log('Google Drive client initialized');
  }
}
```

#### 3.3.4 環境変数

| 変数名 | 説明 | 例 |
|--------|------|-----|
| `GOOGLE_SERVICE_ACCOUNT_KEY` | Service Accountの秘密鍵JSON | `{"type":"service_account",...}` |
| `GDRIVE_ROOT_FOLDER_ID` | ルートフォルダID | `1-z9yZPJwjHQVNkd81JPkx6eookylZHmr` |

**Secret Manager設定**:
```bash
# 秘密鍵をSecret Managerに登録
gcloud secrets create gdrive-sa-key --data-file=sa-key.json

# Cloud Runからアクセス可能にする
gcloud secrets add-iam-policy-binding gdrive-sa-key \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/secretmanager.secretAccessor"
```

---

### 3.4 フォルダ構成

#### 3.4.1 物理フォルダ構成

```
G:\共有ドライブ\dept_TI-経理財務部\経理DX\支払伝票処理自動化\
├── 2024年度/
│   ├── 4月締め/
│   │   ├── 未処理/      ← listFiles() の対象
│   │   └── 処理済み/    ← moveToProcessed() の移動先
│   ├── 5月締め/
│   │   ├── 未処理/
│   │   └── 処理済み/
│   └── ...
├── 2025年度/
│   ├── 4月締め/
│   │   ├── 未処理/
│   │   └── 処理済み/
│   └── ...
└── ...
```

#### 3.4.2 フォルダID管理

| フォルダ | ID | 備考 |
|----------|-----|------|
| ルート（支払伝票処理自動化） | `1-z9yZPJwjHQVNkd81JPkx6eookylZHmr` | 環境変数で管理 |
| 年度フォルダ | 動的 | `ensureFolderStructure()` で取得/作成 |
| 月フォルダ | 動的 | `ensureFolderStructure()` で取得/作成 |
| 未処理/処理済み | 動的 | `ensureFolderStructure()` で取得/作成 |

#### 3.4.3 命名規則

| フォルダ種別 | 命名パターン | 例 |
|--------------|--------------|-----|
| 年度フォルダ | `{年度}年度` | `2025年度` |
| 月フォルダ | `{月}月締め` | `4月締め` |
| 未処理フォルダ | `未処理` | 固定 |
| 処理済みフォルダ | `処理済み` | 固定 |

---

## 補足：getFileContent() を実装しない理由

タスク仕様書より：
> getFileContent() は不要（OCR APIがドメイン委任で直接取得）

OCR APIがService Accountのドメイン委任を使用してGoogle Driveから直接ファイル内容を取得するため、
GdriveServiceでファイル内容取得機能を実装する必要がない。

**処理フロー**:
```
GdriveService.listFiles()
    ↓ ファイルID一覧
OcrService.processFile(fileId)
    ↓ OCR APIがドメイン委任でファイル取得・OCR実行
GdriveService.moveToProcessed(fileId)
```

---

## 依存関係

**npmパッケージ**:
```json
{
  "dependencies": {
    "googleapis": "^140.0.0"
  }
}
```

**NestJSモジュール**:
- `ConfigModule`: 環境変数管理
- `GdriveModule`: 本サービス

---

## 参考資料

- [Google Drive API v3 Reference](https://developers.google.com/drive/api/reference/rest/v3)
- [Google Auth Library for Node.js](https://github.com/googleapis/google-auth-library-nodejs)
- [Service Account認証ガイド](https://cloud.google.com/iam/docs/service-accounts)
